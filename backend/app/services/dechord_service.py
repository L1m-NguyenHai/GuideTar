from __future__ import annotations

import collections
import collections.abc
import math
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Optional, cast
from uuid import uuid4

import numpy as np
from fastapi import HTTPException, Request, UploadFile
from madmom.features.beats import DBNBeatTrackingProcessor, RNNBeatProcessor
from yt_dlp import YoutubeDL

from app.core.database import execute, is_db_ready
from app.core.security import decode_token

# madmom compatibility patches for modern Python/Numpy.
if not hasattr(collections, "MutableSequence"):
    setattr(collections, "MutableSequence", collections.abc.MutableSequence)
if not hasattr(np, "float"):
    np.float = float  # type: ignore[attr-defined]
if not hasattr(np, "int"):
    np.int = int  # type: ignore[attr-defined]

DEFAULT_MODEL_REPO = (Path(__file__).resolve().parents[2] / "Models" / "chord-cnn-lstm-model").resolve()


def detect_beats_madmom(audio_path: Path) -> tuple[list[float], float]:
    beat_activations = RNNBeatProcessor()(str(audio_path))
    beats = DBNBeatTrackingProcessor(fps=100)(beat_activations)
    beat_list = [float(x) for x in beats]

    if len(beat_list) < 2:
        return beat_list, 0.0

    intervals = np.diff(beat_list)
    valid_intervals = intervals[intervals > 0]
    if len(valid_intervals) == 0:
        return beat_list, 0.0

    bpm = float(60.0 / np.median(valid_intervals))
    return beat_list, bpm


def parse_lab_file(lab_path: Path) -> list[dict[str, float | str]]:
    rows: list[dict[str, float | str]] = []
    with lab_path.open("r", encoding="utf-8") as handle:
        for line in handle:
            parts = line.strip().split()
            if len(parts) < 3:
                continue
            rows.append(
                {
                    "start": float(parts[0]),
                    "end": float(parts[1]),
                    "chord": parts[2],
                }
            )
    return rows


def normalize_chord_label(chord: str) -> str:
    if chord in {"N", "N.C.", "N/C", "NC", ""}:
        return "N/C"
    return chord


def beats_to_beat_info(beat_times: list[float], time_signature: int = 4) -> list[dict[str, float | int]]:
    beat_info: list[dict[str, float | int]] = []
    for index, time_value in enumerate(beat_times):
        beat_info.append(
            {
                "time": float(time_value),
                "strength": 0.8,
                "beatNum": (index % max(time_signature, 1)) + 1,
            }
        )
    return beat_info


def score_downbeat_alignment(chord_series: list[str], time_signature: int) -> tuple[float, int]:
    if not isinstance(chord_series, list) or len(chord_series) < 2:
        return 0.0, 0

    def is_valid(chord_value: str) -> bool:
        return bool(chord_value) and chord_value not in {"", "N.C.", "N/C", "N"}

    change_at = [False] * len(chord_series)
    for index in range(1, len(chord_series)):
        previous = chord_series[index - 1]
        current = chord_series[index]
        if is_valid(previous) and is_valid(current) and previous != current:
            change_at[index] = True

    best_shift = 0
    best_score = float("-inf")
    on_weight = 2.0
    off_penalty = 1.0

    for shift in range(time_signature):
        on_down = 0
        off_down = 0
        for index in range(1, len(chord_series)):
            if not change_at[index]:
                continue
            is_downbeat = ((index - shift) % time_signature + time_signature) % time_signature == 0
            if is_downbeat:
                on_down += 1
            else:
                off_down += 1

        score = on_down * on_weight - off_down * off_penalty

        if time_signature == 4:
            on_half = 0
            off_half = 0
            for index in range(1, len(chord_series)):
                if not change_at[index]:
                    continue
                pos_in_bar = ((index - shift) % 4 + 4) % 4
                is_strong_beat = pos_in_bar % 2 == 0
                if is_strong_beat:
                    on_half += 1
                else:
                    off_half += 1
            half_score = (on_half * on_weight - off_half * off_penalty) * 0.5
            score = max(score, half_score)

        if score > best_score:
            best_score = score
            best_shift = shift

    return best_score if best_score != float("-inf") else 0.0, best_shift


def choose_meter_and_downbeats(chords: list[dict[str, float | str]], beat_times: list[float]) -> tuple[int, list[float]]:
    if not beat_times:
        return 4, []

    beat_info = beats_to_beat_info(beat_times, 4)
    synchronized = synchronize_chords(chords, beat_info)
    chord_series = [str(item["chord"]) for item in synchronized]
    score3, _ = score_downbeat_alignment(chord_series, 3)
    score4, _ = score_downbeat_alignment(chord_series, 4)
    winner = 3 if score3 > score4 else 4

    downbeats = [float(beat_times[index]) for index in range(0, len(beat_times), winner) if index < len(beat_times)]
    return winner, downbeats


def estimate_time_signature(beat_times: list[float], chords: list[dict[str, float | str]]) -> int:
    if not beat_times or not chords:
        return 4

    winner, _ = choose_meter_and_downbeats(chords, beat_times)
    return winner


def synchronize_chords(
    chords: list[dict[str, float | str]],
    beats: list[dict[str, float | int]],
) -> list[dict[str, float | int | str]]:
    if not chords or not beats:
        return []

    beat_to_chord: dict[int, str] = {}
    beat_index = 0

    for chord_item in chords:
        chord_start = float(chord_item["start"])
        chord_label = normalize_chord_label(str(chord_item["chord"]))

        while beat_index < len(beats) - 1 and float(beats[beat_index + 1]["time"]) <= chord_start:
            beat_index += 1

        beat_duration = 0.0
        if beat_index < len(beats) - 1:
            beat_duration = float(beats[beat_index + 1]["time"]) - float(beats[beat_index]["time"])
        elif beat_index > 0:
            beat_duration = float(beats[beat_index]["time"]) - float(beats[beat_index - 1]["time"])

        compensated_index = beat_index
        if beat_index > 0 and beat_duration > 0 and chord_start - beat_duration * 0.25 < float(beats[beat_index]["time"]):
            compensated_index = beat_index - 1

        beat_to_chord[compensated_index] = chord_label

    synchronized: list[dict[str, float | int | str]] = []
    last_chord = "N/C"

    for index, beat_item in enumerate(beats):
        chord_label = beat_to_chord.get(index, last_chord)
        synchronized.append(
            {
                "chord": chord_label,
                "beatIndex": index,
                "beatNum": int(beat_item.get("beatNum", (index % 4) + 1)),
            }
        )
        last_chord = chord_label

    return synchronized


def build_grid_alignment_metadata(
    synchronized_chords: list[dict[str, float | int | str]],
    beats: list[dict[str, float | int]],
    time_signature: int,
) -> dict[str, object]:
    if not beats:
        return {
            "paddingCount": 0,
            "shiftCount": 0,
            "totalPaddingCount": 0,
            "gridChords": [],
            "gridBeats": [],
            "originalAudioMapping": [],
            "animationMapping": [],
        }

    first_detected_beat = float(beats[0]["time"])
    bpm = 0.0
    if len(beats) > 1:
        intervals = np.diff([float(item["time"]) for item in beats])
        valid_intervals = intervals[intervals > 0]
        if len(valid_intervals) > 0:
            bpm = float(60.0 / np.median(valid_intervals))

    raw_padding_count = math.floor((first_detected_beat / 60.0) * bpm) if bpm > 0 else 0
    beat_duration = round((60.0 / bpm) * 1000.0) / 1000.0 if bpm > 0 else 0.0
    gap_ratio = first_detected_beat / beat_duration if beat_duration > 0 else 0.0
    padding_count = raw_padding_count if not (raw_padding_count == 0 and gap_ratio > 0.2) else 1

    debug_padding_count = padding_count
    if padding_count == 0 and first_detected_beat > 0.1 and beat_duration > 0:
        debug_padding_count = max(1, math.floor(gap_ratio))

    if debug_padding_count <= 0 or debug_padding_count >= time_signature * 4:
        debug_padding_count = 0

    optimized_padding_count = debug_padding_count
    if debug_padding_count >= time_signature and time_signature > 0:
        full_measures_to_remove = math.floor(debug_padding_count / time_signature)
        optimized_padding_count = debug_padding_count - (full_measures_to_remove * time_signature)
        if optimized_padding_count == 0:
            optimized_padding_count = debug_padding_count % time_signature or time_signature

    synchronized_series = [normalize_chord_label(str(item["chord"])) for item in synchronized_chords]
    _, shift_count = score_downbeat_alignment(synchronized_series, time_signature)
    total_padding_count = optimized_padding_count + shift_count

    padded_chords = ["" for _ in range(shift_count)] + ["N/C" for _ in range(optimized_padding_count)] + synchronized_series

    padding_beats: list[Optional[float]] = []
    if optimized_padding_count > 0 and first_detected_beat > 0:
        padding_step = first_detected_beat / optimized_padding_count
        padding_beats = [round(index * padding_step, 6) for index in range(optimized_padding_count)]

    padded_beats: list[Optional[float]] = [None for _ in range(shift_count)] + padding_beats + [float(item["time"]) for item in beats]
    corrected_beats: list[Optional[float]] = list(padded_beats)

    original_audio_mapping: list[dict[str, float | int | str]] = []
    for index, chord_item in enumerate(synchronized_chords):
        beat_time = float(beats[index]["time"]) if index < len(beats) else 0.0
        original_audio_mapping.append(
            {
                "chord": normalize_chord_label(str(chord_item["chord"])),
                "timestamp": beat_time,
                "visualIndex": total_padding_count + index,
                "audioIndex": index,
            }
        )

    for audio_item in original_audio_mapping:
        chord_label = str(audio_item["chord"])
        if chord_label in {"", "N/C"}:
            continue

        occurrence_index = 0
        for prior in original_audio_mapping:
            if prior is audio_item:
                break
            if str(prior["chord"]) == chord_label:
                occurrence_index += 1

        current_occurrence = 0
        found_visual_index = -1
        for visual_index, visual_chord in enumerate(padded_chords):
            if visual_chord == chord_label:
                if current_occurrence == occurrence_index:
                    found_visual_index = visual_index
                    break
                current_occurrence += 1

        if found_visual_index >= 0:
            audio_item["visualIndex"] = found_visual_index
            corrected_beats[found_visual_index] = float(audio_item["timestamp"])

    animation_mapping: list[dict[str, float | int | str]] = []
    processed: set[str] = set()
    for audio_item in original_audio_mapping:
        chord_label = str(audio_item["chord"])
        if chord_label in {"", "N/C"} or chord_label in processed:
            continue
        animation_mapping.append(
            {
                "timestamp": float(audio_item["timestamp"]),
                "visualIndex": int(audio_item["visualIndex"]),
                "chord": chord_label,
            }
        )
        processed.add(chord_label)

    return {
        "paddingCount": optimized_padding_count,
        "shiftCount": shift_count,
        "totalPaddingCount": total_padding_count,
        "gridChords": padded_chords,
        "gridBeats": corrected_beats,
        "originalAudioMapping": original_audio_mapping,
        "animationMapping": animation_mapping,
    }


def run_chord_cnn_lstm(model_repo: Path, audio_path: Path, out_lab_path: Path, chord_dict: str) -> str:
    script_path = model_repo / "chord_recognition.py"
    if not model_repo.exists():
        raise FileNotFoundError(f"Model repo not found: {model_repo}")
    if not script_path.exists():
        raise FileNotFoundError(f"Missing script: {script_path}")

    cmd = [
        "uv",
        "run",
        "python",
        "chord_recognition.py",
        str(audio_path),
        str(out_lab_path),
        chord_dict,
    ]

    proc = subprocess.run(
        cmd,
        cwd=str(model_repo),
        text=True,
        capture_output=True,
        check=False,
    )

    logs = f"STDOUT:\n{proc.stdout}\n\nSTDERR:\n{proc.stderr}"
    if proc.returncode != 0:
        raise RuntimeError(f"Chord model failed (exit={proc.returncode})\n{logs}")
    if not out_lab_path.exists():
        raise RuntimeError(f"Chord model finished but no output file found: {out_lab_path}\n{logs}")

    return logs


def download_audio_from_youtube(youtube_url: str, tmp_dir: Path) -> tuple[Path, str]:
    output_template = str(tmp_dir / "youtube_audio.%(ext)s")
    ydl_opts = {
        "format": "bestaudio/best",
        "outtmpl": output_template,
        "noplaylist": True,
        "quiet": True,
        "no_warnings": True,
        "postprocessors": [
            {
                "key": "FFmpegExtractAudio",
                "preferredcodec": "mp3",
                "preferredquality": "192",
            }
        ],
    }

    with YoutubeDL(cast(Any, ydl_opts)) as ydl:
        info = ydl.extract_info(youtube_url, download=True)
        prepared_path = Path(ydl.prepare_filename(info))

    mp3_path = prepared_path.with_suffix(".mp3")
    if not mp3_path.exists():
        candidates = sorted(tmp_dir.glob("youtube_audio*.mp3"))
        if not candidates:
            raise RuntimeError("Failed to download audio from YouTube URL.")
        mp3_path = candidates[0]

    title = str(info.get("title") or "youtube_audio")
    return mp3_path, title


def build_analysis_result(
    beat_times: list[float],
    bpm: float,
    chords: list[dict[str, float | str]],
    chord_model: str,
    beat_model: str,
    audio_filename: str | None,
    lab_text: str,
    logs: str | None = None,
) -> dict[str, object]:
    time_signature = estimate_time_signature(beat_times, chords)
    beats = beats_to_beat_info(beat_times, time_signature)
    synchronized = synchronize_chords(chords, beats)
    meter_candidates = choose_meter_and_downbeats(chords, beat_times)[1]
    grid_meta = cast(dict[str, Any], build_grid_alignment_metadata(synchronized, beats, time_signature))

    response: dict[str, object] = {
        "success": True,
        "filename": audio_filename,
        "rawChords": chords,
        "beats": grid_meta["gridBeats"],
        "downbeats": meter_candidates,
        "downbeats_with_measures": [],
        "synchronizedChords": synchronized,
        "chords": grid_meta["gridChords"],
        "rawChordCount": len(chords),
        "chord_count": len(grid_meta["gridChords"]),
        "chordModel": chord_model,
        "beatModel": beat_model,
        "audioDuration": beat_times[-1] if beat_times else 0,
        "beatDetectionResult": {
            "time_signature": time_signature,
            "bpm": bpm,
            "beatShift": int(grid_meta["shiftCount"]),
            "beat_time_range_start": beat_times[0] if beat_times else 0,
            "beat_time_range_end": beat_times[-1] if beat_times else 0,
            "paddingCount": grid_meta["paddingCount"],
            "shiftCount": grid_meta["shiftCount"],
            "beats": grid_meta["gridBeats"],
            "animationRangeStart": beat_times[0] if beat_times else 0,
        },
        "paddingCount": grid_meta["paddingCount"],
        "shiftCount": grid_meta["shiftCount"],
        "totalPaddingCount": grid_meta["totalPaddingCount"],
        "originalAudioMapping": grid_meta["originalAudioMapping"],
        "animationMapping": grid_meta["animationMapping"],
        "lab": lab_text,
    }

    if logs is not None:
        response["logs"] = logs

    return response


def extract_bearer_token(request: Request) -> str | None:
    authorization = request.headers.get("Authorization")
    if not authorization or not authorization.startswith("Bearer "):
        return None
    return authorization.replace("Bearer ", "", 1).strip()


def optional_user_id(request: Request) -> str | None:
    token = extract_bearer_token(request)
    if token is None:
        return None

    try:
        payload = decode_token(token)
    except ValueError:
        return None

    if payload.get("type") != "access":
        return None

    user_id = str(payload.get("sub") or "")
    return user_id or None


async def save_analysis_history(
    request: Request,
    response: dict[str, object],
    filename_for_response: str | None,
    youtube_url: str | None,
) -> None:
    if not is_db_ready():
        return

    user_id = optional_user_id(request)
    analysis_id = str(uuid4())
    beat_detection = response.get("beatDetectionResult")
    detected_bpm = None
    detected_time_signature = 4
    if isinstance(beat_detection, dict):
        detected_bpm = beat_detection.get("bpm")
        detected_time_signature = int(beat_detection.get("time_signature", 4))

    await execute(
        """
        insert into dechord_analyses (
            id, user_id, source_type, source_name, source_url,
            bpm, time_signature, chord_count, raw_chord_count
        )
        values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        """,
        analysis_id,
        user_id,
        "youtube" if youtube_url else "file",
        filename_for_response,
        youtube_url,
        detected_bpm,
        detected_time_signature,
        response.get("chord_count", 0),
        response.get("rawChordCount", 0),
    )

    grid_chords = cast(list[str], response.get("chords", []))
    grid_beats = cast(list[Optional[float]], response.get("beats", []))
    for idx, chord in enumerate(grid_chords):
        beat_value = grid_beats[idx] if idx < len(grid_beats) else None
        await execute(
            """
            insert into dechord_analysis_beats (
                analysis_id, beat_index, beat_time_seconds, chord_label
            )
            values ($1, $2, $3, $4)
            """,
            analysis_id,
            idx,
            beat_value,
            chord,
        )


async def analyze_audio_file_or_url(
    request: Request,
    file: UploadFile | None,
    youtube_url: str | None,
    chord_dict: str,
    model_repo: str,
    include_logs: bool,
) -> dict[str, object]:
    if not file and not youtube_url:
        raise HTTPException(status_code=400, detail="Provide either an MP3 file or youtube_url.")

    if file and file.content_type not in {"audio/mpeg", "audio/mp3", "application/octet-stream"}:
        raise HTTPException(status_code=400, detail="Only MP3 upload is supported.")

    with tempfile.TemporaryDirectory(prefix="guidetar_api_") as tmpdir:
        tmp_dir = Path(tmpdir)
        filename_for_response = file.filename if file else "youtube_audio.mp3"
        audio_path = tmp_dir / "input_audio.mp3"
        lab_path = tmp_dir / "result_chords.lab"

        if file:
            audio_path.write_bytes(await file.read())
        elif youtube_url:
            try:
                downloaded_path, video_title = download_audio_from_youtube(youtube_url, tmp_dir)
                shutil.copy2(downloaded_path, audio_path)
                filename_for_response = f"{video_title}.mp3"
            except Exception as exc:
                raise HTTPException(status_code=400, detail=f"YouTube download failed: {exc}") from exc

        try:
            beats, bpm = detect_beats_madmom(audio_path)
            logs = run_chord_cnn_lstm(Path(model_repo).resolve(), audio_path, lab_path, chord_dict)
            chords = parse_lab_file(lab_path)
            lab_text = lab_path.read_text(encoding="utf-8")
        except FileNotFoundError as exc:
            raise HTTPException(status_code=404, detail=str(exc)) from exc
        except Exception as exc:
            raise HTTPException(status_code=500, detail=str(exc)) from exc

    response = build_analysis_result(
        beat_times=beats,
        bpm=bpm,
        chords=chords,
        chord_model="chord-cnn-lstm",
        beat_model="madmom",
        audio_filename=filename_for_response,
        lab_text=lab_text,
        logs=logs if include_logs else None,
    )

    try:
        await save_analysis_history(request, response, filename_for_response, youtube_url)
    except Exception:
        pass

    return response

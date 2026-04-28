from __future__ import annotations

import csv
import logging
import re
import time
import unicodedata
from typing import Any, TYPE_CHECKING
from pathlib import Path

if TYPE_CHECKING:
    from yt_dlp import YoutubeDL


def _build_query(title: str, artists: str) -> str:
    artists_first = (artists or "").split("|")[0].strip()
    if artists_first:
        return f"{title} {artists_first} official"
    return f"{title} official"


def _normalize_text(text: str) -> str:
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    return text.lower()


def _tokenize(text: str) -> list[str]:
    normalized = _normalize_text(text)
    return [t for t in re.findall(r"[a-z0-9]+", normalized) if len(t) > 1]


def _score_entry(entry: dict, title: str, artists: str) -> int:
    candidate_title = entry.get("title") or ""
    candidate_channel = entry.get("channel") or ""
    candidate_text = f"{candidate_title} {candidate_channel}"
    candidate_norm = _normalize_text(candidate_text)

    song_tokens = _tokenize(title)
    artist_tokens = _tokenize((artists or "").split("|")[0].strip())

    score = 0
    score += sum(3 for t in song_tokens if t in candidate_norm)
    score += sum(4 for t in artist_tokens if t in candidate_norm)

    preferred_markers = ["official", "mv", "music video", "lyric video", "audio"]
    score += sum(2 for marker in preferred_markers if marker in candidate_norm)

    blocked_markers = [
        "cover",
        "karaoke",
        "live",
        "remix",
        "nightcore",
        "sped up",
        "shorts",
        "tiktok",
        "fanmade",
        "reaction",
        "instrumental",
    ]
    score -= sum(4 for marker in blocked_markers if marker in candidate_norm)

    duration = entry.get("duration") or 0
    if 60 <= duration <= 600:
        score += 2
    elif 30 <= duration <= 900:
        score += 1
    else:
        score -= 2

    return score


def _extract_video_and_thumbnail(entry: dict) -> tuple[str, str]:
    video_url = entry.get("webpage_url")
    if not video_url and entry.get("id"):
        video_url = f"https://www.youtube.com/watch?v={entry['id']}"

    thumbnail_url = entry.get("thumbnail") or ""
    if not thumbnail_url:
        thumbs = entry.get("thumbnails") or []
        if thumbs:
            thumbnail_url = (thumbs[-1] or {}).get("url", "")

    return video_url or "", thumbnail_url


def _search_youtube_best(query: str, title: str, artists: str, max_results: int = 5) -> tuple[str, str]:
    from yt_dlp import YoutubeDL

    ydl_opts: dict[str, Any] = {
        "quiet": True,
        "no_warnings": True,
        "skip_download": True,
        "noplaylist": True,
        "ignoreerrors": True,
    }
    with YoutubeDL(ydl_opts) as ydl:  # type: ignore[arg-type]
        info = ydl.extract_info(f"ytsearch{max_results}:{query}", download=False)

    entries = [e for e in (info.get("entries") or []) if e]
    if not entries:
        return "", ""

    best = max(entries, key=lambda e: _score_entry(e or {}, title, artists))
    return _extract_video_and_thumbnail(best or {})


def enrich_csv_with_youtube(csv_path: str, delay_seconds: float = 0.35, search_results: int = 5) -> int:
    path = Path(csv_path)
    if not path.exists():
        raise FileNotFoundError(f"CSV not found: {csv_path}")

    with path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        fieldnames = list(reader.fieldnames or [])

    if not fieldnames:
        raise ValueError("CSV has no header")

    if "youtube_url" not in fieldnames:
        fieldnames.append("youtube_url")
    if "thumbnail_url" not in fieldnames:
        fieldnames.append("thumbnail_url")

    updated = 0
    for i, row in enumerate(rows, start=1):
        title = (row.get("title") or "").strip()
        artists = (row.get("artists") or "").strip()
        if not title:
            row["youtube_url"] = ""
            row["thumbnail_url"] = ""
            continue

        query = _build_query(title, artists)
        try:
            video_url, thumbnail_url = _search_youtube_best(
                query,
                title=title,
                artists=artists,
                max_results=search_results,
            )
        except Exception as exc:  # pragma: no cover - network-dependent
            logging.warning("YouTube lookup failed for row %s (%s): %s", i, title, exc)
            video_url, thumbnail_url = "", ""

        row["youtube_url"] = video_url
        row["thumbnail_url"] = thumbnail_url
        if video_url:
            updated += 1

        if delay_seconds > 0:
            time.sleep(delay_seconds)

    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    return updated

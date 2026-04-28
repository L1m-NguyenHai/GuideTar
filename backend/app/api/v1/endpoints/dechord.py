from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, HTTPException, Request, UploadFile

from app.api.dependencies import get_current_user
from app.core.database import fetch
from app.schemas.dechord import AnalyzeHistoryItem
from app.schemas.user import UserMeResponse
from app.services.dechord_service import DEFAULT_MODEL_REPO, analyze_audio_file_or_url

router = APIRouter(tags=["dechord"])


@router.post("/api/analyze")
async def analyze_audio(
    request: Request,
    file: UploadFile | None = File(None),
    youtube_url: str | None = Form(None),
    chord_dict: str = Form("submission"),
    model_repo: str = Form(str(DEFAULT_MODEL_REPO)),
    include_logs: bool = Form(False),
) -> dict[str, object]:
    return await analyze_audio_file_or_url(
        request=request,
        file=file,
        youtube_url=youtube_url,
        chord_dict=chord_dict,
        model_repo=model_repo,
        include_logs=include_logs,
    )


@router.get("/api/analyze/history", response_model=list[AnalyzeHistoryItem])
async def analyze_history(current_user: UserMeResponse = Depends(get_current_user)) -> list[AnalyzeHistoryItem]:
    rows = await fetch(
        """
        select id::text as id, source_type, source_name, source_url, bpm, time_signature,
               chord_count, raw_chord_count, created_at
        from dechord_analyses
        where user_id = $1
        order by created_at desc
        limit 5
        """,
        current_user.id,
    )
    return [AnalyzeHistoryItem(**dict(row)) for row in rows]


@router.get("/api/analyze/history/{analysis_id}")
async def analyze_history_detail(
    analysis_id: str, current_user: UserMeResponse = Depends(get_current_user)
) -> dict[str, object]:
    analysis = await fetch(
        """
        select id::text as id, source_type, source_name, source_url, bpm, time_signature,
               chord_count, raw_chord_count, created_at
        from dechord_analyses
        where id::text = $1 and user_id = $2
        """,
        analysis_id,
        current_user.id,
    )

    if not analysis:
        raise HTTPException(status_code=404, detail="Analyze history not found")

    analysis_row = dict(analysis[0])

    beats_rows = await fetch(
        """
        select beat_index, beat_time, chord_label
        from dechord_analysis_beats
        where analysis_id::text = $1
        order by beat_index asc
        """,
        analysis_id,
    )

    chords = [dict(row)["chord_label"] or "" for row in beats_rows]

    return {
        "chords": chords,
        "beats": [],
        "beatDetectionResult": {
            "bpm": analysis_row.get("bpm", 0),
            "time_signature": analysis_row.get("time_signature", 4),
        },
        "chord_count": analysis_row.get("chord_count", len(chords)),
        "rawChordCount": analysis_row.get("raw_chord_count", 0),
    }

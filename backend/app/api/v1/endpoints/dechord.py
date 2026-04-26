from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, Request, UploadFile

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
        select id, source_type, source_name, source_url, bpm, time_signature,
               chord_count, raw_chord_count, created_at
        from dechord_analyses
        where user_id = $1
        order by created_at desc
        limit 50
        """,
        current_user.id,
    )
    return [AnalyzeHistoryItem(**dict(row)) for row in rows]

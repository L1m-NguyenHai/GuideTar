from __future__ import annotations
from typing import Any

from fastapi import APIRouter, Depends, File, Form, HTTPException, Request, UploadFile

from app.api.dependencies import get_current_user
from app.core.database import fetch, fetchrow
from app.schemas.dechord import AnalyzeHistoryItem
from app.schemas.user import UserMeResponse
from app.services.dechord_service import DEFAULT_MODEL_REPO, analyze_audio_file_or_url

router = APIRouter(tags=["dechord"])


@router.get("/api/analyze/limit")
async def analyze_limit_status(current_user: UserMeResponse = Depends(get_current_user)) -> dict[str, Any]:
    # Check subscription
    sub = await fetchrow(
        """
        select s.id, s.status, s.renew_at, p.code as plan_code
        from user_subscriptions s
        join subscription_plans p on p.id = s.plan_id
        where s.user_id = $1
        order by s.started_at desc
        limit 1
        """,
        current_user.id,
    )

    # Auto-expire logic: if Maestro plan is past its renew_at date, revert to SOLO
    if sub and sub["plan_code"] == "MAESTRO" and sub["status"] == "active" and sub["renew_at"]:
        from datetime import timezone
        if datetime.now(timezone.utc) > sub["renew_at"]:
            await execute("update user_subscriptions set status = 'expired' where id = $1", sub["id"])
            
            # Revert to SOLO: Try update first, if not exists, insert
            await execute(
                """
                update user_subscriptions 
                set status = 'active', started_at = now(), renew_at = null
                where user_id = $1 and plan_id = (select id from subscription_plans where code = 'SOLO' limit 1)
                """,
                current_user.id,
            )
            await execute(
                """
                insert into user_subscriptions (user_id, plan_id, status)
                select $1, id, 'active' from subscription_plans where code = 'SOLO'
                and not exists (
                    select 1 from user_subscriptions 
                    where user_id = $1 and plan_id = (select id from subscription_plans where code = 'SOLO' limit 1)
                )
                """,
                current_user.id,
            )
            # Re-fetch the updated sub
            sub = await fetchrow(
                """
                select s.id, s.status, s.renew_at, p.code as plan_code
                from user_subscriptions s
                join subscription_plans p on p.id = s.plan_id
                where s.user_id = $1
                order by s.started_at desc
                limit 1
                """,
                current_user.id,
            )

    plan_code = sub["plan_code"] if sub else "SOLO"
    
    if plan_code == "MAESTRO":
        return {
            "plan": "MAESTRO",
            "limit": -1, # Unlimited
            "used": 0,
            "remaining": -1,
            "reset_at": None
        }
    
    # Count usage this week
    usage = await fetchrow(
        """
        select count(*) as used
        from dechord_analyses
        where user_id = $1 and created_at >= date_trunc('week', now())
        """,
        current_user.id
    )
    used = usage["used"] if usage else 0
    limit = 3
    remaining = max(0, limit - used)
    
    import datetime
    # Next Monday 00:00:00
    now = datetime.datetime.now()
    next_reset = (now + datetime.timedelta(days=(7 - now.weekday()))).replace(hour=0, minute=0, second=0, microsecond=0)
    
    return {
        "plan": plan_code,
        "limit": limit,
        "used": used,
        "remaining": remaining,
        "reset_at": next_reset.isoformat()
    }


@router.post("/api/analyze")
async def analyze_audio(
    request: Request,
    file: UploadFile | None = File(None),
    youtube_url: str | None = Form(None),
    chord_dict: str = Form("submission"),
    model_repo: str = Form(str(DEFAULT_MODEL_REPO)),
    include_logs: bool = Form(False),
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, object]:
    # Check limit before processing
    limit_status = await analyze_limit_status(current_user)
    if limit_status["limit"] != -1 and limit_status["remaining"] <= 0:
        raise HTTPException(
            status_code=403, 
            detail="Bạn đã hết lượt phân tích trong tuần này. Vui lòng nâng cấp lên MAESTRO để sử dụng không giới hạn."
        )

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
        select id::text as id, source_type, source_name, source_url,
               to_jsonb(dechord_analyses)->>'thumbnail_url' as thumbnail_url,
               bpm, time_signature,
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
        select id::text as id, source_type, source_name, source_url,
               to_jsonb(dechord_analyses)->>'thumbnail_url' as thumbnail_url,
               bpm, time_signature,
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
        select beat_index, beat_time_seconds, chord_label
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
        "source_type": analysis_row.get("source_type"),
        "source_name": analysis_row.get("source_name"),
        "source_url": analysis_row.get("source_url"),
        "thumbnail_url": analysis_row.get("thumbnail_url"),
    }

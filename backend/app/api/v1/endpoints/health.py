from __future__ import annotations

from fastapi import APIRouter

from app.core.database import is_db_ready

router = APIRouter()


@router.get("/health")
def health() -> dict[str, str]:
    return {
        "status": "ok",
        "db": "ready" if is_db_ready() else "not_configured",
    }

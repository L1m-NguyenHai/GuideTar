from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends

from app.api.dependencies import get_current_user
from app.core.database import execute, fetch
from app.schemas.user import UserMeResponse

router = APIRouter(prefix="/notes", tags=["notes"])


@router.get("/")
async def get_user_notes(current_user: UserMeResponse = Depends(get_current_user)) -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select id, date, type, title, content, linked_song, linked_lesson, created_at, user_id
        from user_notes
        where user_id = $1
        order by date desc
        """,
        current_user.id,
    )
    return [dict(row) for row in rows]


@router.post("/")
async def create_user_note(
    title: str,
    content: str | None = None,
    note_type: str | None = None,
    linked_song: str | None = None,
    linked_lesson: str | None = None,
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, Any]:
    note_id = await fetch(
        """
        insert into user_notes (user_id, title, content, type, linked_song, linked_lesson)
        values ($1, $2, $3, $4, $5, $6)
        returning id
        """,
        current_user.id,
        title,
        content,
        note_type,
        linked_song,
        linked_lesson,
    )
    return {"id": note_id[0]["id"] if note_id else None, "detail": "Note created"}


@router.delete("/{note_id}")
async def delete_user_note(note_id: str, current_user: UserMeResponse = Depends(get_current_user)) -> dict[str, str]:
    await execute(
        """
        delete from user_notes
        where id = $1 and user_id = $2
        """,
        note_id,
        current_user.id,
    )
    return {"detail": "Note deleted"}

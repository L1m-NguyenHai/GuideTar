from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends

from app.api.dependencies import get_current_user
from app.core.database import execute, fetch
from app.schemas.user import UserMeResponse

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.get("/songs")
async def get_favorite_songs(current_user: UserMeResponse = Depends(get_current_user)) -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select s.id, s.title, s.artist, s.duration_seconds, s.thumbnail_url, s.youtube_url, f.created_at as favorited_at
        from user_favorite_songs f
        join songs s on s.id = f.song_id
        where f.user_id = $1
        order by f.created_at desc
        """,
        current_user.id,
    )
    return [dict(row) for row in rows]


@router.post("/songs/{song_id}")
async def add_favorite_song(song_id: str, current_user: UserMeResponse = Depends(get_current_user)) -> dict[str, str]:
    await execute(
        """
        insert into user_favorite_songs (user_id, song_id)
        values ($1, $2)
        on conflict (user_id, song_id) do nothing
        """,
        current_user.id,
        song_id,
    )
    return {"detail": "Song added to favorites"}


@router.delete("/songs/{song_id}")
async def remove_favorite_song(song_id: str, current_user: UserMeResponse = Depends(get_current_user)) -> dict[str, str]:
    await execute(
        """
        delete from user_favorite_songs
        where user_id = $1 and song_id = $2
        """,
        current_user.id,
        song_id,
    )
    return {"detail": "Song removed from favorites"}


@router.get("/lessons")
async def get_favorite_lessons(current_user: UserMeResponse = Depends(get_current_user)) -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select l.id, l.title, l.description, l.level, l.thumbnail_url, f.created_at as favorited_at
        from user_favorite_lessons f
        join lessons l on l.id = f.lesson_id
        where f.user_id = $1
        order by f.created_at desc
        """,
        current_user.id,
    )
    return [dict(row) for row in rows]


@router.post("/lessons/{lesson_id}")
async def add_favorite_lesson(
    lesson_id: str,
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, str]:
    await execute(
        """
        insert into user_favorite_lessons (user_id, lesson_id)
        values ($1, $2)
        on conflict (user_id, lesson_id) do nothing
        """,
        current_user.id,
        lesson_id,
    )
    return {"detail": "Lesson added to favorites"}


@router.delete("/lessons/{lesson_id}")
async def remove_favorite_lesson(
    lesson_id: str,
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, str]:
    await execute(
        """
        delete from user_favorite_lessons
        where user_id = $1 and lesson_id = $2
        """,
        current_user.id,
        lesson_id,
    )
    return {"detail": "Lesson removed from favorites"}


@router.get("/recent-lessons")
async def get_recent_lessons(current_user: UserMeResponse = Depends(get_current_user)) -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select l.id, l.title, l.description, l.level, l.thumbnail_url, rl.created_at, rl.last_activated
        from user_recent_lessons rl
        join lessons l on l.id = rl.lesson_id
        where rl.user_id = $1
        order by rl.last_activated desc
        """,
        current_user.id,
    )
    return [dict(row) for row in rows]

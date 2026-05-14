from __future__ import annotations

from typing import Any
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query

from app.core.database import fetch, fetchrow
from app.schemas.piano_lesson import PianoLesson, PianoLessonPractice

router = APIRouter(prefix="/lessons", tags=["lessons"])


@router.get("/piano")
async def get_all_piano_lessons(
    limit: int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
) -> list[dict[str, Any]]:
    """
    Get all piano lessons with pagination.

    Args:
        limit: Maximum number of lessons to return (default: 50, max: 100)
        offset: Number of lessons to skip (default: 0)

    Returns:
        List of piano lessons
    """
    rows = await fetch(
        """
        SELECT id, title, description, level, thumbnail_url, created_at,
               number_of_practice, number_of_song
        FROM public.piano_lessons
        ORDER BY created_at ASC
        LIMIT $1 OFFSET $2
        """,
        limit,
        offset,
    )
    return [dict(row) for row in rows]


@router.get("/piano/{lesson_id}/practices")
async def get_piano_lesson_practices(lesson_id: UUID) -> list[dict[str, Any]]:
    """
    Get all practices for a specific piano lesson.

    Args:
        lesson_id: UUID of the piano lesson

    Returns:
        List of practices for the lesson, ordered by practice order

    Raises:
        HTTPException: If lesson not found
    """
    # Verify lesson exists
    lesson = await fetchrow(
        "SELECT id FROM public.piano_lessons WHERE id = $1",
        lesson_id,
    )
    if lesson is None:
        raise HTTPException(status_code=404, detail="Lesson not found")

    rows = await fetch(
        """
        SELECT id, lesson_id, title, description, est_time, "order", created_at, img_url
        FROM public.piano_lesson_practices
        WHERE lesson_id = $1
        ORDER BY "order" ASC, created_at ASC
        """,
        lesson_id,
    )
    return [dict(row) for row in rows]


@router.get("/piano/{lesson_id}/songs")
async def get_piano_lesson_songs(lesson_id: UUID) -> list[dict[str, Any]]:
    """
    Get all songs for a specific piano lesson.

    Args:
        lesson_id: UUID of the piano lesson

    Returns:
        List of songs for the lesson with grade and song details

    Raises:
        HTTPException: If lesson not found
    """
    # Verify lesson exists
    lesson = await fetchrow(
        "SELECT id FROM public.piano_lessons WHERE id = $1",
        lesson_id,
    )
    if lesson is None:
        raise HTTPException(status_code=404, detail="Lesson not found")

    rows = await fetch(
        """
        SELECT pls.id, pls.created_at, pls.piano_song_id, pls.grade, pls.lesson_id,
               ps.name, ps.author, ps.type, ps.thumbnail_url,
               ps.created_at as song_created_at
        FROM public.piano_lesson_song pls
        JOIN public.piano_song ps ON pls.piano_song_id = ps.id
        WHERE pls.lesson_id = $1
        ORDER BY pls.created_at ASC
        """,
        lesson_id,
    )
    return [dict(row) for row in rows]

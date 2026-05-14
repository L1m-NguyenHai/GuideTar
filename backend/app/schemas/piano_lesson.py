from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel


class PianoLessonPractice(BaseModel):
    id: UUID
    lesson_id: UUID
    title: str | None = None
    description: str | None = None
    est_time: int | None = None
    order: int | None = None
    created_at: datetime
    img_url: str | None = None


class PianoLesson(BaseModel):
    id: UUID
    title: str
    description: str | None = None
    level: str | None = None
    thumbnail_url: str | None = None
    created_at: datetime
    number_of_practice: int | None = None
    number_of_song: int | None = None


class PianoPiece(BaseModel):
    id: UUID
    name: str | None = None
    author: str | None = None
    type: str | None = None
    thumbnail_url: str | None = None
    created_at: datetime


class PianoLessonSong(BaseModel):
    id: int
    created_at: datetime
    piano_song_id: UUID
    grade: str | None = None
    lesson_id: UUID

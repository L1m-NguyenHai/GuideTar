from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel


class AnalyzeHistoryItem(BaseModel):
    id: str
    source_type: str
    source_name: str | None = None
    source_url: str | None = None
    thumbnail_url: str | None = None
    bpm: float | None = None
    time_signature: int | None = None
    chord_count: int
    raw_chord_count: int
    created_at: datetime

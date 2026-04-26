from __future__ import annotations

from datetime import date

from pydantic import BaseModel


class WeeklyAnalyticsResponse(BaseModel):
    week_start: date
    week_end: date
    total_minutes: int
    total_songs: int
    total_lessons: int
    days: list[dict[str, int | date]]

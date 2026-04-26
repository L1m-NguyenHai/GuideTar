from __future__ import annotations

from datetime import date, timedelta

from fastapi import APIRouter, Depends

from app.api.dependencies import get_current_user
from app.core.database import fetch
from app.schemas.analytics import WeeklyAnalyticsResponse
from app.schemas.user import UserMeResponse

router = APIRouter(prefix="/analytics", tags=["analytics"])


@router.get("/weekly", response_model=WeeklyAnalyticsResponse)
async def analytics_weekly(
    week_start: date | None = None,
    current_user: UserMeResponse = Depends(get_current_user),
) -> WeeklyAnalyticsResponse:
    today = date.today()
    start_date = week_start or (today - timedelta(days=today.weekday()))
    end_date = start_date + timedelta(days=6)

    rows = await fetch(
        """
        select stat_date, practice_minutes, song_count, lesson_count
        from practice_daily_stats
        where user_id = $1 and stat_date between $2 and $3
        order by stat_date asc
        """,
        current_user.id,
        start_date,
        end_date,
    )

    stats_map: dict[date, dict[str, int]] = {
        row["stat_date"]: {
            "practice_minutes": int(row["practice_minutes"]),
            "song_count": int(row["song_count"]),
            "lesson_count": int(row["lesson_count"]),
        }
        for row in rows
    }

    days: list[dict[str, int | date]] = []
    total_minutes = 0
    total_songs = 0
    total_lessons = 0
    for offset in range(7):
        day = start_date + timedelta(days=offset)
        current = stats_map.get(day, {"practice_minutes": 0, "song_count": 0, "lesson_count": 0})
        total_minutes += current["practice_minutes"]
        total_songs += current["song_count"]
        total_lessons += current["lesson_count"]
        days.append(
            {
                "date": day,
                "practice_minutes": current["practice_minutes"],
                "song_count": current["song_count"],
                "lesson_count": current["lesson_count"],
            }
        )

    return WeeklyAnalyticsResponse(
        week_start=start_date,
        week_end=end_date,
        total_minutes=total_minutes,
        total_songs=total_songs,
        total_lessons=total_lessons,
        days=days,
    )

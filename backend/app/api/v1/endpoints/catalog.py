from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Query

from app.core.database import fetch

router = APIRouter(prefix="/catalog", tags=["catalog"])


@router.get("/recommended")
async def get_recommended_songs(limit: int = Query(default=10, ge=1, le=50)) -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select id, title, artist, thumbnail_url, youtube_url, source_url, source_song_id,
               key_original, rhythm_name, chord_set, lyrics
        from songs
        where title is not null and title <> ''
        order by created_at desc, title asc
        limit $1
        """,
        limit,
    )
    return [dict(row) for row in rows]


@router.get("/artists")
async def get_artists(limit: int = Query(default=20, ge=1, le=100)) -> list[dict[str, Any]]:
    profile_rows = await fetch(
        """
        select name as artist_name, image_url, image_source, song_count
        from artist_profiles
        order by song_count desc, name asc
        limit $1
        """,
        limit,
    )
    if profile_rows:
        return [dict(row) for row in profile_rows]

    fallback_rows = await fetch(
        """
        select artist as artist_name, null::text as image_url, null::text as image_source, count(*)::int as song_count
        from songs
        where artist is not null and artist <> ''
        group by artist
        order by song_count desc, artist asc
        limit $1
        """,
        limit,
    )
    return [dict(row) for row in fallback_rows]

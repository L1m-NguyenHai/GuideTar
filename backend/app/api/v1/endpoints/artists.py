from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends, Header, HTTPException

from app.api.dependencies import get_current_user
from app.core.database import execute, fetch, fetchrow
from app.core.security import decode_token
from app.schemas.user import UserMeResponse

router = APIRouter(prefix="/artists", tags=["artists"])


async def _optional_user_id(authorization: str | None = Header(default=None)) -> str | None:
    if not authorization or not authorization.startswith("Bearer "):
        return None

    token = authorization.replace("Bearer ", "", 1).strip()
    try:
        payload = decode_token(token)
    except ValueError:
        return None

    if payload.get("type") != "access":
        return None

    user_id = str(payload.get("sub") or "")
    return user_id or None


def _normalize_artist_name(artist_name: str) -> str:
    return artist_name.strip()


async def _artist_exists(artist_name: str) -> bool:
    row = await fetchrow(
        """
        select name
        from artist_profiles
        where lower(name) = lower($1)
        limit 1
        """,
        artist_name,
    )
    return row is not None


@router.get("/{artist_name}")
async def get_artist_detail(
    artist_name: str,
    current_user_id: str | None = Depends(_optional_user_id),
) -> dict[str, Any]:
    normalized_name = _normalize_artist_name(artist_name)

    profile = await fetchrow(
        """
        select name, image_url, image_source, song_count
        from artist_profiles
        where lower(name) = lower($1)
        limit 1
        """,
        normalized_name,
    )

    if profile is None:
        raise HTTPException(status_code=404, detail="Artist not found")

    followers_row = await fetchrow(
        """
        select count(*)::int as followers_count
        from user_followed_artists
        where lower(artist_name) = lower($1)
        """,
        normalized_name,
    )

    is_following = False
    if current_user_id:
        followed_row = await fetchrow(
            """
            select 1
            from user_followed_artists
            where user_id = $1 and lower(artist_name) = lower($2)
            limit 1
            """,
            current_user_id,
            normalized_name,
        )
        is_following = followed_row is not None

    songs = await fetch(
        """
        select id, title, artist, thumbnail_url, youtube_url, source_url, source_song_id
        from songs
        where artist is not null
          and artist <> ''
          and (
              lower(artist) = lower($1)
              or lower(artist) like '%' || lower($1) || '%'
          )
        order by created_at desc, title asc
        limit 8
        """,
        normalized_name,
    )

    return {
        "artist_name": profile["name"],
        "image_url": profile["image_url"],
        "image_source": profile["image_source"],
        "song_count": profile["song_count"],
        "followers_count": (followers_row["followers_count"] if followers_row else 0),
        "is_following": is_following,
        "popular_songs": [dict(row) for row in songs],
    }


@router.post("/{artist_name}/follow")
async def follow_artist(
    artist_name: str,
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, str]:
    normalized_name = _normalize_artist_name(artist_name)
    if not await _artist_exists(normalized_name):
        raise HTTPException(status_code=404, detail="Artist not found")

    await execute(
        """
        insert into user_followed_artists (user_id, artist_name)
        values ($1, $2)
        on conflict (user_id, artist_name) do nothing
        """,
        current_user.id,
        normalized_name,
    )
    return {"detail": "Artist followed"}


@router.delete("/{artist_name}/follow")
async def unfollow_artist(
    artist_name: str,
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, str]:
    normalized_name = _normalize_artist_name(artist_name)
    await execute(
        """
        delete from user_followed_artists
        where user_id = $1 and lower(artist_name) = lower($2)
        """,
        current_user.id,
        normalized_name,
    )
    return {"detail": "Artist unfollowed"}


@router.get("/me/following")
async def get_followed_artists(current_user: UserMeResponse = Depends(get_current_user)) -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select a.name as artist_name, a.image_url, a.image_source, a.song_count, f.created_at as followed_at
        from user_followed_artists f
        left join artist_profiles a on lower(a.name) = lower(f.artist_name)
        where f.user_id = $1
        order by f.created_at desc
        """,
        current_user.id,
    )
    return [dict(row) for row in rows]

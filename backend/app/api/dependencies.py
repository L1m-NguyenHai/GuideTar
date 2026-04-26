from __future__ import annotations

from typing import Any

from fastapi import Header, HTTPException

from app.core.database import fetchrow
from app.core.security import decode_token
from app.schemas.user import UserMeResponse


def _map_user_row(row: Any) -> UserMeResponse:
    row_dict = dict(row)
    return UserMeResponse(
        id=str(row_dict["id"]),
        email=str(row_dict["email"]),
        username=str(row_dict["username"]),
        display_name=row_dict.get("display_name"),
        avatar_url=row_dict.get("avatar_url"),
        bio=row_dict.get("bio"),
        rank_label=row_dict.get("rank_label"),
    )


async def get_user_by_id(user_id: str) -> UserMeResponse:
    row = await fetchrow(
        """
        select u.id, u.email, u.username, p.display_name, p.avatar_url, p.bio, p.rank_label
        from users u
        left join user_profiles p on p.user_id = u.id
        where u.id = $1
        """,
        user_id,
    )
    if row is None:
        raise HTTPException(status_code=401, detail="User not found")
    return _map_user_row(row)


async def get_current_user(authorization: str | None = Header(default=None)) -> UserMeResponse:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")

    token = authorization.replace("Bearer ", "", 1).strip()
    try:
        payload = decode_token(token)
    except ValueError as exc:
        raise HTTPException(status_code=401, detail="Invalid token") from exc

    if payload.get("type") != "access":
        raise HTTPException(status_code=401, detail="Invalid access token")

    user_id = str(payload.get("sub") or "")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token subject")

    return await get_user_by_id(user_id)

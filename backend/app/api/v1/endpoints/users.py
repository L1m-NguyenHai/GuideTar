from __future__ import annotations

from fastapi import APIRouter, Depends

from app.api.dependencies import get_current_user, get_user_by_id
from app.core.database import execute
from app.schemas.user import UpdateProfileRequest, UserMeResponse

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserMeResponse)
async def get_me(current_user: UserMeResponse = Depends(get_current_user)) -> UserMeResponse:
    return current_user


@router.patch("/me", response_model=UserMeResponse)
async def update_me(
    payload: UpdateProfileRequest,
    current_user: UserMeResponse = Depends(get_current_user),
) -> UserMeResponse:
    await execute(
        """
        update user_profiles
        set display_name = coalesce($2, display_name),
            avatar_url = coalesce($3, avatar_url),
            bio = coalesce($4, bio),
            updated_at = now()
        where user_id = $1
        """,
        current_user.id,
        payload.display_name,
        str(payload.avatar_url) if payload.avatar_url else None,
        payload.bio,
    )
    return await get_user_by_id(current_user.id)

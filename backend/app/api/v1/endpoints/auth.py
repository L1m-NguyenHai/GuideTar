from __future__ import annotations

from fastapi import APIRouter, HTTPException

from app.api.dependencies import get_user_by_id
from app.core.database import execute, fetchrow
from app.core.security import create_access_token, create_refresh_token, decode_token, hash_password, verify_password
from app.schemas.auth import ForgotPasswordRequest, LoginRequest, RefreshRequest, RegisterRequest
from app.schemas.user import TokenPairResponse, UserMeResponse

router = APIRouter(prefix="/auth", tags=["auth"])


def _build_token_response(user: UserMeResponse) -> TokenPairResponse:
    return TokenPairResponse(
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id),
        user=user,
    )


@router.post("/register", response_model=TokenPairResponse)
async def register(payload: RegisterRequest) -> TokenPairResponse:
    existing_email = await fetchrow("select 1 from users where lower(email) = lower($1)", payload.email)
    if existing_email is not None:
        raise HTTPException(status_code=409, detail="Email already exists")

    existing_username = await fetchrow("select 1 from users where username = $1", payload.username)
    if existing_username is not None:
        raise HTTPException(status_code=409, detail="Username already exists")

    user_row = await fetchrow(
        """
        insert into users (email, password_hash, username)
        values ($1, $2, $3)
        returning id
        """,
        payload.email,
        hash_password(payload.password),
        payload.username,
    )
    if user_row is None:
        raise HTTPException(status_code=500, detail="Failed to create user")

    await execute(
        """
        insert into user_profiles (user_id, display_name)
        values ($1, $2)
        on conflict (user_id) do nothing
        """,
        user_row["id"],
        payload.username,
    )

    user = await get_user_by_id(str(user_row["id"]))
    return _build_token_response(user)


@router.post("/login", response_model=TokenPairResponse)
async def login(payload: LoginRequest) -> TokenPairResponse:
    row = await fetchrow(
        """
        select id, password_hash
        from users
        where lower(email) = lower($1)
        """,
        payload.email,
    )
    if row is None:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if not verify_password(payload.password, str(row["password_hash"])):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    user = await get_user_by_id(str(row["id"]))
    return _build_token_response(user)


@router.post("/refresh", response_model=TokenPairResponse)
async def refresh_token(payload: RefreshRequest) -> TokenPairResponse:
    try:
        token_payload = decode_token(payload.refresh_token)
    except ValueError as exc:
        raise HTTPException(status_code=401, detail="Invalid refresh token") from exc

    if token_payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    user_id = str(token_payload.get("sub") or "")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    user = await get_user_by_id(user_id)
    return _build_token_response(user)


@router.post("/forgot-password")
async def forgot_password(_: ForgotPasswordRequest) -> dict[str, str]:
    return {"detail": "If the account exists, a reset email will be sent."}

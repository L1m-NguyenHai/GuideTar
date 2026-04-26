from __future__ import annotations

import os
from datetime import datetime, timedelta, timezone
from typing import Any

from jose import JWTError, jwt
from passlib.context import CryptContext

pwd_context = CryptContext(
    # pbkdf2_sha256 avoids bcrypt's 72-byte password limit and the current
    # bcrypt backend incompatibility in this environment.
    schemes=["pbkdf2_sha256"],
    deprecated="auto",
)


def _secret_key() -> str:
    return os.getenv("JWT_SECRET_KEY", "dev-only-change-me")


def _algorithm() -> str:
    return os.getenv("JWT_ALGORITHM", "HS256")


def _access_exp_minutes() -> int:
    return int(os.getenv("JWT_ACCESS_EXPIRE_MINUTES", "30"))


def _refresh_exp_days() -> int:
    return int(os.getenv("JWT_REFRESH_EXPIRE_DAYS", "30"))


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def _encode_token(subject: str, expires_delta: timedelta, token_type: str) -> str:
    now = datetime.now(timezone.utc)
    payload: dict[str, Any] = {
        "sub": subject,
        "type": token_type,
        "iat": int(now.timestamp()),
        "exp": int((now + expires_delta).timestamp()),
    }
    return jwt.encode(payload, _secret_key(), algorithm=_algorithm())


def create_access_token(user_id: str) -> str:
    return _encode_token(
        subject=user_id,
        expires_delta=timedelta(minutes=_access_exp_minutes()),
        token_type="access",
    )


def create_refresh_token(user_id: str) -> str:
    return _encode_token(
        subject=user_id,
        expires_delta=timedelta(days=_refresh_exp_days()),
        token_type="refresh",
    )


def decode_token(token: str) -> dict[str, Any]:
    try:
        return jwt.decode(token, _secret_key(), algorithms=[_algorithm()])
    except JWTError as exc:
        raise ValueError("Invalid token") from exc

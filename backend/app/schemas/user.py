from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, EmailStr, Field, HttpUrl


class UserMeResponse(BaseModel):
    id: str
    email: EmailStr
    username: str
    display_name: str | None = None
    avatar_url: str | None = None
    bio: str | None = None
    rank_label: str | None = None


class UpdateProfileRequest(BaseModel):
    display_name: str | None = Field(default=None, max_length=120)
    avatar_url: HttpUrl | None = None
    bio: str | None = Field(default=None, max_length=1000)


class TokenPairResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: Literal["bearer"] = "bearer"
    user: UserMeResponse

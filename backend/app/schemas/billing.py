from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field


class BillingPayRequest(BaseModel):
    amount: float = Field(gt=0)
    currency: str = Field(default="VND", min_length=3, max_length=8)
    method_type: Literal["card", "qr"] = "qr"
    subscription_id: str | None = None

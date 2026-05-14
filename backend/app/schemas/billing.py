from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field


class BillingPayRequest(BaseModel):
    amount: float = Field(gt=0)
    currency: str = Field(default="VND", min_length=3, max_length=8)
    method_type: Literal["card", "qr", "vnpay"] = "vnpay"
    subscription_id: str | None = None
    plan_id: str | None = None
    billing_cycle: Literal["monthly", "yearly"] | None = "monthly"


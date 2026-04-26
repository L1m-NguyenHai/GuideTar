from __future__ import annotations

from typing import Any
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException

from app.api.dependencies import get_current_user
from app.core.database import execute, fetch, fetchrow
from app.schemas.billing import BillingPayRequest
from app.schemas.user import UserMeResponse

router = APIRouter(prefix="/billing", tags=["billing"])


@router.get("/plans")
async def billing_plans() -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select id, code, name, price_monthly, price_yearly, currency, trial_days, is_active
        from subscription_plans
        where is_active = true
        order by code asc
        """
    )
    return [dict(row) for row in rows]


@router.get("/subscription")
async def billing_subscription(current_user: UserMeResponse = Depends(get_current_user)) -> dict[str, Any] | None:
    row = await fetchrow(
        """
        select s.id, s.status, s.started_at, s.renew_at, s.canceled_at,
               p.id as plan_id, p.code as plan_code, p.name as plan_name
        from user_subscriptions s
        join subscription_plans p on p.id = s.plan_id
        where s.user_id = $1
        order by s.started_at desc
        limit 1
        """,
        current_user.id,
    )
    return dict(row) if row else None


@router.post("/subscription/cancel")
async def cancel_subscription(current_user: UserMeResponse = Depends(get_current_user)) -> dict[str, str]:
    row = await fetchrow(
        """
        update user_subscriptions
        set status = 'canceled', canceled_at = now()
        where id = (
            select id
            from user_subscriptions
            where user_id = $1 and status in ('active', 'trial')
            order by started_at desc
            limit 1
        )
        returning id
        """,
        current_user.id,
    )
    if row is None:
        raise HTTPException(status_code=404, detail="No active subscription found")
    return {"detail": "Subscription canceled"}


@router.get("/transactions")
async def billing_transactions(current_user: UserMeResponse = Depends(get_current_user)) -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select id, subscription_id, payment_code, amount, currency, status, method_type, paid_at, created_at
        from payment_transactions
        where user_id = $1
        order by created_at desc
        """,
        current_user.id,
    )
    return [dict(row) for row in rows]


@router.post("/pay")
async def billing_pay(
    payload: BillingPayRequest,
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, Any]:
    payment_code = f"PAY-{uuid4().hex[:12].upper()}"
    row = await fetchrow(
        """
        insert into payment_transactions (
            user_id, subscription_id, payment_code, amount, currency, status, method_type
        )
        values ($1, $2, $3, $4, $5, 'pending', $6)
        returning id, payment_code, amount, currency, status, method_type, created_at
        """,
        current_user.id,
        payload.subscription_id,
        payment_code,
        payload.amount,
        payload.currency,
        payload.method_type,
    )
    if row is None:
        raise HTTPException(status_code=500, detail="Cannot create payment")
    return dict(row)

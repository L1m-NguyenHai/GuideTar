from __future__ import annotations

import os
from datetime import datetime
from typing import Any
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import RedirectResponse

from app.api.dependencies import get_current_user
from app.core.database import execute, fetch, fetchrow
from app.schemas.billing import BillingPayRequest
from app.schemas.user import UserMeResponse
from app.services.vnpay_service import VNPay

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
    
    if not row:
        return None

    # Auto-expire logic: if Maestro plan is past its renew_at date, revert to SOLO
    if row["plan_code"] == "MAESTRO" and row["status"] == "active" and row["renew_at"]:
        from datetime import timezone
        if datetime.now(timezone.utc) > row["renew_at"]:
            # Mark current as expired
            await execute("update user_subscriptions set status = 'expired' where id = $1", row["id"])
            
            # Revert to SOLO: Try update first, if not exists, insert
            await execute(
                """
                update user_subscriptions 
                set status = 'active', started_at = now(), renew_at = null
                where user_id = $1 and plan_id = (select id from subscription_plans where code = 'SOLO' limit 1)
                """,
                current_user.id,
            )
            await execute(
                """
                insert into user_subscriptions (user_id, plan_id, status)
                select $1, id, 'active' from subscription_plans where code = 'SOLO'
                and not exists (
                    select 1 from user_subscriptions 
                    where user_id = $1 and plan_id = (select id from subscription_plans where code = 'SOLO' limit 1)
                )
                """,
                current_user.id,
            )
            
            # Fetch the updated subscription
            return await billing_subscription(current_user)

    return dict(row)


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
    
    # After canceling, automatically assign back to SOLO plan
    await execute(
        """
        update user_subscriptions 
        set status = 'active', started_at = now(), renew_at = null
        where user_id = $1 and plan_id = (select id from subscription_plans where code = 'SOLO' limit 1)
        """,
        current_user.id,
    )
    await execute(
        """
        insert into user_subscriptions (user_id, plan_id, status)
        select $1, id, 'active' from subscription_plans where code = 'SOLO'
        and not exists (
            select 1 from user_subscriptions 
            where user_id = $1 and plan_id = (select id from subscription_plans where code = 'SOLO' limit 1)
        )
        """,
        current_user.id,
    )
    
    return {"detail": "Subscription canceled and reverted to SOLO"}


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


@router.post("/pay/vnpay")
async def billing_pay_vnpay(
    payload: BillingPayRequest,
    request: Request,
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, Any]:
    payment_code = f"PAY-{uuid4().hex[:12].upper()}"
    row = await fetchrow(
        """
        insert into payment_transactions (
            user_id, subscription_id, payment_code, amount, currency, status, method_type,
            plan_id, billing_cycle
        )
        values ($1, $2, $3, $4, $5, 'pending', 'vnpay', $6, $7)
        returning id, payment_code, amount, currency, status, method_type, created_at
        """,
        current_user.id,
        payload.subscription_id,
        payment_code,
        payload.amount,
        payload.currency,
        payload.plan_id,
        payload.billing_cycle,
    )
    if row is None:
        raise HTTPException(status_code=500, detail="Cannot create payment transaction")

    vnp_tmn_code = os.getenv("VNPAY_TMN_CODE", "UW7PC62G")
    vnp_hash_secret = os.getenv("VNPAY_HASH_SECRET", "728VECY0YN8U4Q5QYSOE9O5IF0RYCC46")
    vnp_pay_url = os.getenv("VNPAY_PAYMENT_URL", "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html")
    vnp_return_url = os.getenv("VNPAY_RETURN_URL", "http://10.0.2.2:8000/billing/vnpay/return")

    vnp = VNPay(vnp_tmn_code, vnp_hash_secret, vnp_pay_url, vnp_return_url)

    # Convert amount to VNPay format: Amount * 100
    amount = int(payload.amount * 100)

    ipaddr = request.client.host if request.client else "127.0.0.1"
    create_date = datetime.now().strftime("%Y%m%d%H%M%S")

    vnpay_data = {
        "vnp_Version": "2.1.0",
        "vnp_Command": "pay",
        "vnp_TmnCode": vnp_tmn_code,
        "vnp_Amount": str(amount),
        "vnp_CurrCode": payload.currency,
        "vnp_TxnRef": payment_code,
        "vnp_OrderInfo": f"Thanh toan don hang {payment_code}",
        "vnp_OrderType": "billpayment",
        "vnp_Locale": "vn",
        "vnp_ReturnUrl": vnp_return_url,
        "vnp_IpAddr": ipaddr,
        "vnp_CreateDate": create_date,
    }

    # Generate the VNPay payment URL
    payment_url = vnp.get_payment_url(vnpay_data)
    
    response = dict(row)
    response["payment_url"] = payment_url
    return response


@router.get("/vnpay/return")
async def billing_vnpay_return(request: Request) -> Any:
    # Handle the IPN/Return from VNPay
    vnp_tmn_code = os.getenv("VNPAY_TMN_CODE", "UW7PC62G")
    vnp_hash_secret = os.getenv("VNPAY_HASH_SECRET", "728VECY0YN8U4Q5QYSOE9O5IF0RYCC46")
    vnp_pay_url = os.getenv("VNPAY_PAYMENT_URL", "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html")
    vnp_return_url = os.getenv("VNPAY_RETURN_URL", "http://10.0.2.2:8000/billing/vnpay/return")

    vnp = VNPay(vnp_tmn_code, vnp_hash_secret, vnp_pay_url, vnp_return_url)
    
    # Store response query params in VNPay
    vnp.responseData = dict(request.query_params)
    
    vnp_SecureHash = request.query_params.get("vnp_SecureHash")
    payment_code = request.query_params.get("vnp_TxnRef")
    vnp_ResponseCode = request.query_params.get("vnp_ResponseCode")

    if not vnp_SecureHash or not payment_code:
        raise HTTPException(status_code=400, detail="Invalid callback")

    if vnp.validate_response(vnp_SecureHash):
        if vnp_ResponseCode == '00':
            # Payment Successful
            tx_row = await fetchrow(
                """
                update payment_transactions
                set status = 'paid', paid_at = now()
                where payment_code = $1
                returning id, user_id, plan_id, billing_cycle
                """,
                payment_code,
            )
            
            if tx_row:
                user_id = tx_row["user_id"]
                tx_id = tx_row["id"]
                plan_id = tx_row["plan_id"]
                billing_cycle = tx_row["billing_cycle"]
                
                # If plan_id is missing from transaction, fallback to first plan (legacy support)
                if not plan_id:
                    plan_row = await fetchrow(
                        "select id from subscription_plans order by code desc limit 1" # Prefer MAESTRO
                    )
                    if plan_row:
                        plan_id = plan_row["id"]
                
                if plan_id:
                    # Deactivate existing subs for user
                    await execute(
                        "update user_subscriptions set status = 'expired' where user_id = $1 and status = 'active'",
                        user_id
                    )
                    
                    # Calculate renewal date
                    from datetime import timedelta
                    now = datetime.now()
                    if billing_cycle == 'yearly':
                        renew_at = now + timedelta(days=365)
                    else:
                        # Simple 30 days for monthly
                        renew_at = now + timedelta(days=30)
                    
                    # Insert the new active subscription
                    sub_row = await fetchrow(
                        """
                        insert into user_subscriptions (user_id, plan_id, status, started_at, renew_at)
                        values ($1, $2, 'active', $3, $4)
                        returning id
                        """,
                        user_id, plan_id, now, renew_at
                    )
                    
                    # Link transaction to the sub
                    if sub_row:
                        await execute(
                            "update payment_transactions set subscription_id = $1 where id = $2",
                            sub_row["id"], tx_id
                        )

            # Instead of returning JSON, redirect to a deep link to return to the app
            return RedirectResponse(f"guidetar://payment-result?status=success&payment_code={payment_code}")
        else:
            # Payment Failed
            await execute(
                """
                update payment_transactions
                set status = 'failed'
                where payment_code = $1
                """,
                payment_code,
            )
            # Redirect back to app on failure
            return RedirectResponse(f"guidetar://payment-result?status=failed&payment_code={payment_code}")
    else:
        raise HTTPException(status_code=400, detail="Invalid signature")

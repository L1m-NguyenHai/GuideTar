from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends, HTTPException

from app.api.dependencies import get_current_user
from app.core.database import fetch, fetchrow
from app.schemas.support import SupportMessageRequest
from app.schemas.user import UserMeResponse

router = APIRouter(prefix="/support", tags=["support"])


@router.get("/categories")
async def support_categories() -> list[dict[str, Any]]:
    rows = await fetch(
        """
        select id, code, name, sort_order
        from faq_categories
        order by sort_order asc, name asc
        """
    )
    return [dict(row) for row in rows]


@router.get("/faqs")
async def support_faqs(category_code: str | None = None) -> list[dict[str, Any]]:
    if category_code:
        rows = await fetch(
            """
            select f.id, f.question, f.answer, f.sort_order, c.code as category_code, c.name as category_name
            from faqs f
            join faq_categories c on c.id = f.category_id
            where f.is_active = true and c.code = $1
            order by f.sort_order asc
            """,
            category_code,
        )
        return [dict(row) for row in rows]

    rows = await fetch(
        """
        select f.id, f.question, f.answer, f.sort_order, c.code as category_code, c.name as category_name
        from faqs f
        join faq_categories c on c.id = f.category_id
        where f.is_active = true
        order by c.sort_order asc, f.sort_order asc
        """
    )
    return [dict(row) for row in rows]


@router.get("/conversations/{conversation_id}/messages")
async def support_messages(
    conversation_id: str,
    current_user: UserMeResponse = Depends(get_current_user),
) -> list[dict[str, Any]]:
    owner = await fetchrow(
        """
        select id
        from support_conversations
        where id = $1 and user_id = $2
        """,
        conversation_id,
        current_user.id,
    )
    if owner is None:
        raise HTTPException(status_code=404, detail="Conversation not found")

    rows = await fetch(
        """
        select id, sender_type, message_text, created_at
        from support_messages
        where conversation_id = $1
        order by created_at asc
        """,
        conversation_id,
    )
    return [dict(row) for row in rows]


@router.post("/conversations/{conversation_id}/messages")
async def send_support_message(
    conversation_id: str,
    payload: SupportMessageRequest,
    current_user: UserMeResponse = Depends(get_current_user),
) -> dict[str, Any]:
    owner = await fetchrow(
        """
        select id
        from support_conversations
        where id = $1 and user_id = $2
        """,
        conversation_id,
        current_user.id,
    )
    if owner is None:
        raise HTTPException(status_code=404, detail="Conversation not found")

    message = await fetchrow(
        """
        insert into support_messages (conversation_id, sender_type, message_text)
        values ($1, 'user', $2)
        returning id, sender_type, message_text, created_at
        """,
        conversation_id,
        payload.message_text,
    )
    if message is None:
        raise HTTPException(status_code=500, detail="Failed to send message")

    return dict(message)

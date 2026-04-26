from __future__ import annotations

import asyncio
import logging
import os
from typing import Any

import asyncpg
from fastapi import HTTPException

_pool: asyncpg.Pool | None = None
logger = logging.getLogger(__name__)


def _get_database_url() -> str | None:
    return os.getenv("SUPABASE_DB_URL") or os.getenv("DATABASE_URL")


async def init_db_pool() -> None:
    global _pool
    if _pool is not None:
        return

    database_url = _get_database_url()
    if not database_url:
        return

    try:
        _pool = await asyncio.wait_for(
            asyncpg.create_pool(
                dsn=database_url,
                min_size=1,
                max_size=10,
                statement_cache_size=0,
            ),
            timeout=5,
        )
    except Exception as exc:
        _pool = None
        logger.warning("DB pool init failed; running without DB: %s", exc)


async def close_db_pool() -> None:
    global _pool
    if _pool is None:
        return
    await _pool.close()
    _pool = None


def is_db_ready() -> bool:
    return _pool is not None


def require_db() -> asyncpg.Pool:
    if _pool is None:
        raise HTTPException(
            status_code=503,
            detail="Database is not configured. Set SUPABASE_DB_URL and restart server.",
        )
    return _pool


async def fetchrow(query: str, *args: Any) -> asyncpg.Record | None:
    pool = require_db()
    async with pool.acquire() as conn:
        return await conn.fetchrow(query, *args)


async def fetch(query: str, *args: Any) -> list[asyncpg.Record]:
    pool = require_db()
    async with pool.acquire() as conn:
        return await conn.fetch(query, *args)


async def execute(query: str, *args: Any) -> str:
    pool = require_db()
    async with pool.acquire() as conn:
        return await conn.execute(query, *args)

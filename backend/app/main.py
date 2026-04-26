from __future__ import annotations

from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from app.api.v1.router import api_router
from app.core.database import close_db_pool, init_db_pool


load_dotenv(Path(__file__).resolve().parents[1] / ".env")


@asynccontextmanager
async def lifespan(_: FastAPI):
    await init_db_pool()
    yield
    await close_db_pool()


app = FastAPI(
    title="GuideTarBackend API",
    version="0.1.0",
    description="FastAPI backend for GuideTar features and DeChord analysis.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)

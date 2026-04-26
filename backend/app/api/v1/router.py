from __future__ import annotations

from fastapi import APIRouter

from app.api.v1.endpoints.analytics import router as analytics_router
from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.billing import router as billing_router
from app.api.v1.endpoints.dechord import router as dechord_router
from app.api.v1.endpoints.favorites import router as favorites_router
from app.api.v1.endpoints.health import router as health_router
from app.api.v1.endpoints.support import router as support_router
from app.api.v1.endpoints.users import router as users_router

api_router = APIRouter()

api_router.include_router(health_router)
api_router.include_router(dechord_router)
api_router.include_router(auth_router)
api_router.include_router(users_router)
api_router.include_router(billing_router)
api_router.include_router(favorites_router)
api_router.include_router(analytics_router)
api_router.include_router(support_router)

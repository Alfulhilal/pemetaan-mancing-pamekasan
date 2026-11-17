from fastapi import APIRouter
from app.api.v1.endpoints import spots, tides, smca, catch_log

api_router = APIRouter()

api_router.include_router(spots.router, prefix="/spots", tags=["Titik Pemancingan & Radar Geospasial"])
api_router.include_router(tides.router, prefix="/tides", tags=["Telemetri Pasut & Golden Window"])
api_router.include_router(smca.router, prefix="/smca", tags=["Laboratorium & Simulasi SMCA"])
api_router.include_router(catch_log.router, prefix="/catch-log", tags=["Validasi Ground Truth & Catch Log"])

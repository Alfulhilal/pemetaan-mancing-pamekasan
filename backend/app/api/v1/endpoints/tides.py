from fastapi import APIRouter
from app.services.tide_service import tide_service

router = APIRouter()

@router.get("/curve-24h", summary="Kurva elevasi pasang surut 24 jam & deteksi Golden Window")
def get_tide_curve_24h():
    curve = tide_service.get_24h_tide_curve()
    telemetry = tide_service.get_telemetry_now()
    return {
        "status": "success",
        "station": "Stasiun Maritim Selat Madura & Pesisir Pamekasan",
        "current_telemetry": telemetry,
        "curve_data": curve
    }

@router.get("/current", summary="Kondisi telemetri pasut & cuaca laut real-time")
def get_current_telemetry():
    return tide_service.get_telemetry_now()

import uuid
from datetime import datetime
from fastapi import APIRouter, HTTPException
from app.schemas.spot import CatchLogCreate, CatchLogResponse
from app.services.gis_service import gis_service

router = APIRouter()

# Penyimpanan in-memory log tangkapan untuk prototype
catch_logs_db = []

@router.post("/", response_model=CatchLogResponse, summary="Merekam log tangkapan pemancing terverifikasi GPS")
def create_catch_log(log_in: CatchLogCreate):
    spot = gis_service.get_spot_by_id(log_in.spot_id)
    if not spot:
        raise HTTPException(status_code=404, detail="Titik spot tidak valid")

    # Validasi jarak GPS pengirim terhadap koordinat spot
    spot_lat = spot["coordinates"]["latitude"]
    spot_lng = spot["coordinates"]["longitude"]
    dist_m = gis_service.haversine_distance(log_in.latitude, log_in.longitude, spot_lat, spot_lng)

    # Validasi GPS: jika berada dalam radius 3.000 meter dari spot maka dianggap verified ground truth
    is_verified = dist_m <= 3000.0

    record = {
        "id": str(uuid.uuid4()),
        "spot_id": log_in.spot_id,
        "angler_name": log_in.angler_name,
        "species": log_in.species,
        "weight_kg": log_in.weight_kg,
        "verified_gps": is_verified,
        "distance_to_spot_m": round(dist_m, 1),
        "created_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S WIB")
    }
    catch_logs_db.append(record)

    return CatchLogResponse(**record)

@router.get("/spot/{spot_id}", summary="Mengambil riwayat tangkapan komunitas pada spot tertentu")
def get_spot_catch_logs(spot_id: str):
    matched = [log for log in catch_logs_db if log["spot_id"] == spot_id]
    return {
        "spot_id": spot_id,
        "total_records": len(matched),
        "records": matched
    }

from fastapi import APIRouter, Query, HTTPException
from typing import Optional
from app.schemas.spot import RadarResponse, SpotDetailResponse, RadarSpotItem
from app.services.gis_service import gis_service
from app.services.smca_engine import smca_engine
from app.services.tide_service import tide_service
from app.core.config import settings

router = APIRouter()

@router.get("/radar", response_model=RadarResponse, summary="Mengambil titik spot dalam radius buffer radar 5 KM")
def get_radar_spots(
    lat: float = Query(settings.DEFAULT_LATITUDE, description="Latitude posisi pengguna"),
    lng: float = Query(settings.DEFAULT_LONGITUDE, description="Longitude posisi pengguna"),
    radius: float = Query(settings.DEFAULT_SEARCH_RADIUS_METERS, description="Radius buffer dalam meter (default 5000)")
):
    raw_spots, latency_ms = gis_service.get_spots_within_radius(lat, lng, radius)
    telemetry = tide_service.get_telemetry_now()
    evaluated_spots = smca_engine.evaluate_spots(raw_spots, telemetry=telemetry)

    formatted_items = []
    for s in evaluated_spots:
        item = RadarSpotItem(
            id=s["id"],
            name=s["name"],
            district=s["district"],
            zone=s["zone"],
            depth_meter=s["depth_meter"],
            substrate=s["substrate"],
            target_species=s["target_species"],
            recommended_bait=s["recommended_bait"],
            accessibility_km=s["accessibility_km"],
            coordinates=s["coordinates"],
            distance_meters=s["distance_meters"],
            smca_score=s["smca_score"],
            strike_zone_active=True if s["smca_score"] >= 0.85 else False,
            tide_elevation_meter=telemetry["elevation_meter"],
            current_velocity_ms=telemetry["current_velocity_ms"],
            wind_knots=telemetry["wind_speed_knots"],
            wave_height_meter=telemetry["wave_height_meter"]
        )
        formatted_items.append(item)

    top_spot = formatted_items[0] if formatted_items else None

    return RadarResponse(
        user_location={"latitude": lat, "longitude": lng},
        radius_meters=radius,
        total_spots_found=len(formatted_items),
        top_recommended_spot=top_spot,
        spots=formatted_items,
        query_latency_ms=latency_ms
    )

@router.get("/{spot_id}", response_model=SpotDetailResponse, summary="Detail lengkap titik spot & oseanografi")
def get_spot_detail(
    spot_id: str,
    lat: Optional[float] = Query(settings.DEFAULT_LATITUDE),
    lng: Optional[float] = Query(settings.DEFAULT_LONGITUDE)
):
    spot = gis_service.get_spot_by_id(spot_id)
    if not spot:
        raise HTTPException(status_code=404, detail="Titik spot tidak ditemukan")

    dist = gis_service.haversine_distance(
        lat, lng, spot["coordinates"]["latitude"], spot["coordinates"]["longitude"]
    )
    spot["distance_meters"] = round(dist, 1)

    telemetry = tide_service.get_telemetry_now()
    eval_list = smca_engine.evaluate_spots([spot], telemetry=telemetry)
    evaluated = eval_list[0]

    return SpotDetailResponse(
        id=evaluated["id"],
        name=evaluated["name"],
        district=evaluated["district"],
        zone=evaluated["zone"],
        depth_meter=evaluated["depth_meter"],
        substrate=evaluated["substrate"],
        target_species=evaluated["target_species"],
        recommended_bait=evaluated["recommended_bait"],
        accessibility_km=evaluated["accessibility_km"],
        coordinates=evaluated["coordinates"],
        smca_score=evaluated["smca_score"],
        criteria_scores=evaluated["criteria_scores"],
        golden_window=telemetry["golden_window"],
        weather_summary=telemetry
    )

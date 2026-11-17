from pydantic import BaseModel, Field
from typing import List, Optional

class Coordinates(BaseModel):
    longitude: float
    latitude: float

class SpotBase(BaseModel):
    id: str
    name: str
    district: str
    zone: str
    depth_meter: float
    substrate: str
    target_species: List[str]
    recommended_bait: str
    accessibility_km: float

class RadarSpotItem(SpotBase):
    coordinates: Coordinates
    distance_meters: float
    smca_score: float
    strike_zone_active: bool
    tide_elevation_meter: float
    current_velocity_ms: float
    wind_knots: float
    wave_height_meter: float

class RadarResponse(BaseModel):
    user_location: Coordinates
    radius_meters: float
    total_spots_found: int
    top_recommended_spot: Optional[RadarSpotItem] = None
    spots: List[RadarSpotItem]
    query_latency_ms: float

class SpotDetailResponse(SpotBase):
    coordinates: Coordinates
    smca_score: float
    criteria_scores: dict
    golden_window: str
    weather_summary: dict

class CatchLogCreate(BaseModel):
    spot_id: str
    angler_name: str
    species: str
    weight_kg: float
    latitude: float
    longitude: float
    notes: Optional[str] = ""
    photo_base64: Optional[str] = None

class CatchLogResponse(BaseModel):
    id: str
    spot_id: str
    angler_name: str
    species: str
    weight_kg: float
    verified_gps: bool
    distance_to_spot_m: float
    created_at: str

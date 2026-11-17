from pydantic import BaseModel, Field
from typing import List, Optional

class SMCACriteriaWeights(BaseModel):
    # 5 Kriteria Utama SMCA
    w_accessibility: float = Field(0.20, ge=0.0, le=1.0, description="Bobot Jarak Aksesibilitas (Cost)")
    w_tide_current: float = Field(0.25, ge=0.0, le=1.0, description="Bobot Arus Pasut / Golden Window (Benefit)")
    w_weather_safety: float = Field(0.20, ge=0.0, le=1.0, description="Bobot Keselamatan Cuaca Angin & Gelombang (Cost)")
    w_substrate: float = Field(0.20, ge=0.0, le=1.0, description="Bobot Substrat Karang & Kedalaman (Benefit)")
    w_community_rating: float = Field(0.15, ge=0.0, le=1.0, description="Bobot Ulasan & Histori Tangkapan (Benefit)")

class SMCASimulationSpotRank(BaseModel):
    rank: int
    spot_id: str
    spot_name: str
    district: str
    distance_meters: float
    raw_scores: dict
    composite_smca_score: float
    previous_rank: Optional[int] = None

class SMCASimulationRequest(BaseModel):
    user_latitude: float = -7.2185
    user_longitude: float = 113.4842
    weights: SMCACriteriaWeights

class SMCASimulationResponse(BaseModel):
    normalized_weights: SMCACriteriaWeights
    ranked_spots: List[SMCASimulationSpotRank]
    spearman_rank_correlation: float
    computation_time_ms: float

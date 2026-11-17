import os
from pydantic import BaseModel

class Settings(BaseModel):
    PROJECT_NAME: str = "Sistem Pemetaan & Rekomendasi Titik Pemancingan Pesisir Pamekasan"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Lokasi data
    DATA_DIR: str = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../data"))
    SPOTS_GEOJSON_PATH: str = os.path.join(DATA_DIR, "spots_pamekasan.geojson")
    
    # Koordinat Pusat Pesisir Pamekasan (Default: Pantai Branta / Tlanakan)
    DEFAULT_LATITUDE: float = -7.2185
    DEFAULT_LONGITUDE: float = 113.4842
    DEFAULT_SEARCH_RADIUS_METERS: float = 5000.0  # 5 KM Buffer Radar

settings = Settings()

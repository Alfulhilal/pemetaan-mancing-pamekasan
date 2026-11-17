import sys
import os

# Tambahkan backend ke path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json()["status"] == "healthy"
    print("PASS: /health")

def test_radar_spots():
    res = client.get("/api/v1/spots/radar?lat=-7.2185&lng=113.4842&radius=5000")
    assert res.status_code == 200
    data = res.json()
    assert data["total_spots_found"] > 0
    assert data["top_recommended_spot"] is not None
    print(f"PASS: /spots/radar - Found {data['total_spots_found']} spots, Top: {data['top_recommended_spot']['name']}")

def test_tide_curve():
    res = client.get("/api/v1/tides/curve-24h")
    assert res.status_code == 200
    data = res.json()
    assert len(data["curve_data"]) == 24
    print("PASS: /tides/curve-24h - 24 hours curve generated")

def test_smca_simulation():
    payload = {
        "user_latitude": -7.2185,
        "user_longitude": 113.4842,
        "weights": {
            "w_accessibility": 0.40,
            "w_tide_current": 0.20,
            "w_weather_safety": 0.10,
            "w_substrate": 0.20,
            "w_community_rating": 0.10
        }
    }
    res = client.post("/api/v1/smca/simulate", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert len(data["ranked_spots"]) > 0
    print(f"PASS: /smca/simulate - Spearman rho: {data['spearman_rank_correlation']}")

def test_catch_log():
    payload = {
        "spot_id": "spot-001",
        "angler_name": "Alful Hilal",
        "species": "Kakap Merah",
        "weight_kg": 3.8,
        "latitude": -7.2180,
        "longitude": 113.4840,
        "notes": "Strike saat arus mulai surut di Branta"
    }
    res = client.post("/api/v1/catch-log/", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["verified_gps"] is True
    print(f"PASS: /catch-log/ - Verified: {data['verified_gps']}, Dist: {data['distance_to_spot_m']}m")

if __name__ == "__main__":
    print("=== RUNNING BACKEND TESTS ===")
    test_health()
    test_radar_spots()
    test_tide_curve()
    test_smca_simulation()
    test_catch_log()
    print("=== ALL 5 TESTS PASSED SUCCESSFULLY! ===")

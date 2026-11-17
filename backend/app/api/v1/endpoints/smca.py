import time
from fastapi import APIRouter
from app.schemas.smca import SMCASimulationRequest, SMCASimulationResponse, SMCASimulationSpotRank
from app.services.gis_service import gis_service
from app.services.smca_engine import smca_engine

router = APIRouter()

@router.post("/simulate", response_model=SMCASimulationResponse, summary="Simulasi analisis sensitivitas bobot kriteria SMCA secara interaktif")
def simulate_smca_weights(request: SMCASimulationRequest):
    t_start = time.perf_counter()

    # Dapatkan seluruh spot (radius diperluas untuk laboratorium)
    raw_spots, _ = gis_service.get_spots_within_radius(
        request.user_latitude, request.user_longitude, radius_meters=100000.0
    )

    # 1. Evaluasi dengan bobot default untuk baseline ranking
    baseline_spots = smca_engine.evaluate_spots(raw_spots, weights=smca_engine.default_weights)
    baseline_rank_map = {s["id"]: idx + 1 for idx, s in enumerate(baseline_spots)}

    # 2. Evaluasi dengan bobot kustom dari slider pengguna
    simulated_spots = smca_engine.evaluate_spots(raw_spots, weights=request.weights)

    ranked_items = []
    actual_ranks = []
    predicted_ranks = []

    for idx, s in enumerate(simulated_spots):
        current_rank = idx + 1
        prev_rank = baseline_rank_map.get(s["id"], current_rank)
        
        actual_ranks.append(prev_rank)
        predicted_ranks.append(current_rank)

        ranked_items.append(SMCASimulationSpotRank(
            rank=current_rank,
            spot_id=s["id"],
            spot_name=s["name"],
            district=s["district"],
            distance_meters=s["distance_meters"],
            raw_scores=s["criteria_scores"],
            composite_smca_score=s["smca_score"],
            previous_rank=prev_rank
        ))

    # Korelasi Spearman antara peringkat default vs kustom
    spearman_rho = smca_engine.calculate_spearman_rank_correlation(actual_ranks, predicted_ranks)
    elapsed_ms = round((time.perf_counter() - t_start) * 1000, 2)

    return SMCASimulationResponse(
        normalized_weights=request.weights,
        ranked_spots=ranked_items,
        spearman_rank_correlation=spearman_rho,
        computation_time_ms=elapsed_ms
    )

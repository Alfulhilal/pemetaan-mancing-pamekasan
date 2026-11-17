import numpy as np
from typing import List, Dict, Any, Tuple
from app.schemas.smca import SMCACriteriaWeights, SMCASimulationSpotRank

class SMCAEngine:
    def __init__(self):
        # Bobot default kriteria
        self.default_weights = SMCACriteriaWeights()

    @staticmethod
    def normalize_min_max(value: float, min_val: float, max_val: float, is_cost: bool = False) -> float:
        """
        Normalisasi kriteria menggunakan linear scaling (Benefit vs Cost).
        """
        if max_val == min_val:
            return 1.0
        if is_cost:
            # Semakin kecil semakin bagus (misal: jarak tempuh & kecepatan angin)
            norm = (max_val - value) / (max_val - min_val)
        else:
            # Semakin besar semakin bagus (misal: arus makan, kualitas karang, ulasan nelayan)
            norm = (value - min_val) / (max_val - min_val)
        return float(np.clip(norm, 0.05, 1.0))

    def evaluate_spots(
        self,
        spots: List[Dict[str, Any]],
        weights: SMCACriteriaWeights = None,
        telemetry: Dict[str, Any] = None
    ) -> List[Dict[str, Any]]:
        """
        Menghitung nilai komposit SMCA untuk sekumpulan titik spot.
        """
        if not spots:
            return []

        w = weights or self.default_weights
        
        # Normalisasi total bobot menjadi 1.0
        total_w = (
            w.w_accessibility +
            w.w_tide_current +
            w.w_weather_safety +
            w.w_substrate +
            w.w_community_rating
        )
        if total_w <= 0:
            total_w = 1.0
        
        w1 = w.w_accessibility / total_w
        w2 = w.w_tide_current / total_w
        w3 = w.w_weather_safety / total_w
        w4 = w.w_substrate / total_w
        w5 = w.w_community_rating / total_w

        # Ekstraksi rentang nilai untuk normalisasi
        distances = [s.get("distance_meters", 1000.0) for s in spots]
        min_dist, max_dist = min(distances), max(distances)

        evaluated = []
        for s in spots:
            dist = s.get("distance_meters", 1500.0)
            depth = s.get("depth_meter", 7.0)
            substrate_raw = s.get("substrate", "")

            # Skor Kriteria 1: Aksesibilitas Jarak (Cost)
            c1_norm = self.normalize_min_max(dist, min_dist, max_dist, is_cost=True)

            # Skor Kriteria 2: Arus Pasut / Strike Zone (Benefit)
            # Spot karang tubir Branta & Talang Siring memiliki respon arus makan sangat baik
            c2_base = 0.88 if "Branta" in s.get("name", "") else (0.84 if "Talang Siring" in s.get("name", "") else 0.78)
            c2_norm = round(c2_base, 2)

            # Skor Kriteria 3: Keselamatan Cuaca Angin & Gelombang (Cost)
            # Pesisir selatan lebih terlindung dibanding pantai utara saat musim angin tenggara
            c3_base = 0.92 if s.get("zone", "").startswith("Selatan") else 0.82
            c3_norm = round(c3_base, 2)

            # Skor Kriteria 4: Substrat Karang & Kedalaman (Benefit)
            c4_base = 0.95 if "Tubir" in substrate_raw else (0.85 if "Dangkal" in substrate_raw else 0.75)
            c4_norm = round(c4_base, 2)

            # Skor Kriteria 5: Histori Ulasan & Tangkapan Nelayan (Benefit)
            c5_base = s.get("initial_smca_score", 0.80)
            c5_norm = round(float(c5_base), 2)

            # Formula Komposit SMCA
            composite_score = (
                (w1 * c1_norm) +
                (w2 * c2_norm) +
                (w3 * c3_norm) +
                (w4 * c4_norm) +
                (w5 * c5_norm)
            )
            composite_score = round(float(composite_score), 2)

            evaluated.append({
                **s,
                "smca_score": composite_score,
                "criteria_scores": {
                    "c1_accessibility": round(c1_norm, 2),
                    "c2_tide_current": round(c2_norm, 2),
                    "c3_weather_safety": round(c3_norm, 2),
                    "c4_substrate": round(c4_norm, 2),
                    "c5_community_rating": round(c5_norm, 2)
                }
            })

        # Urutkan berdasarkan skor SMCA tertinggi
        evaluated.sort(key=lambda x: x["smca_score"], reverse=True)
        return evaluated

    @staticmethod
    def calculate_spearman_rank_correlation(ranks_actual: List[int], ranks_predicted: List[int]) -> float:
        """
        Menghitung korelasi peringkat Spearman (rho):
        rho = 1 - (6 * sum(d_i^2)) / (n * (n^2 - 1))
        """
        n = len(ranks_actual)
        if n <= 1:
            return 1.0
        d_sq_sum = sum((a - p) ** 2 for a, p in zip(ranks_actual, ranks_predicted))
        rho = 1.0 - (6.0 * d_sq_sum) / (n * ((n ** 2) - 1.0))
        return round(float(rho), 2)

smca_engine = SMCAEngine()

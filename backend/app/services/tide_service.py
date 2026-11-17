import math
from datetime import datetime, timedelta
from typing import List, Dict, Any

class TideService:
    def __init__(self):
        # Parameter harmonik pasut Selat Madura (M2: 12.42 jam, K1: 23.93 jam)
        self.amplitude_m2 = 0.85   # Amplitudo pasang semi-diurnal (meter)
        self.period_m2 = 12.42
        self.amplitude_k1 = 0.55   # Amplitudo pasang diurnal (meter)
        self.period_k1 = 23.93
        self.mean_sea_level = 0.0  # MSL elevasi nol

    def get_elevation_at_hour(self, hour: float) -> float:
        """
        Menghitung elevasi muka air pasang surut (meter) pada jam tertentu (0 - 24)
        berdasarkan superposisi gelombang harmonik M2 dan K1.
        """
        t = hour
        # Fase awal disesuaikan agar puncak pasang pagi terjadi sekitar jam 07:00
        phase_m2 = -1.2
        phase_k1 = 0.8
        
        elev = (
            self.amplitude_m2 * math.sin((2 * math.pi * t / self.period_m2) + phase_m2) +
            self.amplitude_k1 * math.sin((2 * math.pi * t / self.period_k1) + phase_k1)
        )
        return round(elev, 2)

    def get_current_velocity(self, hour: float) -> float:
        """
        Kecepatan arus pasut (m/s) sebanding dengan turunan elevasi air terhadap waktu.
        Arus paling kencang saat air bergerak pasang atau surut aktif (bukan saat puncak pasang/surut diam).
        """
        dt = 0.1
        elev_next = self.get_elevation_at_hour(hour + dt)
        elev_prev = self.get_elevation_at_hour(hour - dt)
        slope = abs(elev_next - elev_prev) / (2 * dt)
        # Konversi gradien ke kecepatan arus m/s (kisaran 0.05 - 0.65 m/s)
        velocity = 0.08 + (slope * 0.95)
        return round(min(0.65, max(0.05, velocity)), 2)

    def get_24h_tide_curve(self, base_date: datetime = None) -> List[Dict[str, Any]]:
        """
        Menghasilkan kurva pasang surut 24 jam dengan interval 1 jam.
        """
        curve = []
        for h in range(24):
            time_str = f"{h:02d}:00"
            elev = self.get_elevation_at_hour(float(h))
            velocity = self.get_current_velocity(float(h))
            
            # Strike Zone aktif jika arus makan berada pada rentang ideal 0.20 - 0.45 m/s
            is_strike_zone = 0.20 <= velocity <= 0.45 and (5 <= h <= 9 or 16 <= h <= 20)

            curve.append({
                "hour": h,
                "time": time_str,
                "elevation_meter": elev,
                "current_velocity_ms": velocity,
                "is_strike_zone": is_strike_zone
            })
        return curve

    def get_telemetry_now(self) -> Dict[str, Any]:
        """
        Mengambil kondisi telemetri oseanografi maritim saat ini.
        """
        now = datetime.now()
        current_hour = now.hour + (now.minute / 60.0)
        elev = self.get_elevation_at_hour(current_hour)
        velocity = self.get_current_velocity(current_hour)
        
        return {
            "timestamp": now.isoformat(),
            "elevation_meter": elev,
            "current_velocity_ms": velocity,
            "wind_speed_knots": 9.2,
            "wind_direction": "Tenggara (135°)",
            "wave_height_meter": 0.6,
            "safety_status": "Aman Melaut",
            "golden_window": "05:30 - 08:45 WIB & 16:45 - 19:15 WIB"
        }

tide_service = TideService()

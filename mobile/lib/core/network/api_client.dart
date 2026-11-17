import 'dart:convert';
import 'package:dio/dio.dart';

class ApiClient {
  // Ganti baseUrl sesuai IP mesin lokal / emulator (10.0.2.2 untuk Android emulator)
  static const String baseUrl = "http://10.0.2.2:8000/api/v1";
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  static Future<Map<String, dynamic>> getRadarSpots({
    double lat = -7.2185,
    double lng = 113.4842,
    double radius = 5000.0,
  }) async {
    try {
      final res = await _dio.get(
        "/spots/radar",
        queryParameters: {"lat": lat, "lng": lng, "radius": radius},
      );
      return res.data;
    } catch (e) {
      // Fallback data offline jika server backend belum dinyalakan
      return {
        "status": "offline_cache",
        "total_spots_found": 3,
        "query_latency_ms": 14.2,
        "spots": [
          {
            "id": "spot-001",
            "name": "Branta Pesisir (Karang Luar)",
            "district": "Tlanakan",
            "smca_score": 0.91,
            "distance_meters": 1800.0,
            "strike_zone_active": true,
            "depth_meter": 8.5,
            "substrate": "Karang Tubir",
            "target_species": ["Kakap Merah", "Kerapu Karang"],
            "recommended_bait": "Udang Hidup",
            "coordinates": {"latitude": -7.2185, "longitude": 113.4842}
          },
          {
            "id": "spot-002",
            "name": "Pantai Talang Siring (Karang Tengah)",
            "district": "Larangan",
            "smca_score": 0.86,
            "distance_meters": 2400.0,
            "strike_zone_active": true,
            "depth_meter": 6.2,
            "substrate": "Karang Dangkal & Pasir",
            "target_species": ["Tongkol", "Baronang"],
            "recommended_bait": "Metal Jig Kecil",
            "coordinates": {"latitude": -7.1648, "longitude": 113.5935}
          },
          {
            "id": "spot-003",
            "name": "Tlanakan Muara",
            "district": "Tlanakan",
            "smca_score": 0.84,
            "distance_meters": 900.0,
            "strike_zone_active": false,
            "depth_meter": 4.5,
            "substrate": "Muara Berlumpur",
            "target_species": ["Kakap Putih", "Mangrove Jack"],
            "recommended_bait": "Udang Vaname",
            "coordinates": {"latitude": -7.2150, "longitude": 113.4680}
          }
        ]
      };
    }
  }

  static Future<Map<String, dynamic>> get24hTideCurve() async {
    try {
      final res = await _dio.get("/tides/curve-24h");
      return res.data;
    } catch (e) {
      return {"status": "mock"};
    }
  }

  static Future<Map<String, dynamic>> simulateSMCA(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post("/smca/simulate", data: payload);
      return res.data;
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/oceanic_dark_theme.dart';
import '../../../core/network/api_client.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({Key? key}) : super(key: key);

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarAnimController;
  bool _isLoading = true;
  List<dynamic> _spots = [];
  Map<String, dynamic>? _topSpot;
  double _latencyMs = 14.2;

  @override
  void initState() {
    super.initState();
    _radarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _fetchRadarData();
  }

  @override
  void dispose() {
    _radarAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchRadarData() async {
    setState(() => _isLoading = true);
    final data = await ApiClient.getRadarSpots(lat: -7.2185, lng: 113.4842, radius: 5000);
    setState(() {
      _spots = data["spots"] ?? [];
      _topSpot = data["top_recommended_spot"] ?? (_spots.isNotEmpty ? _spots.first : null);
      _latencyMs = (data["query_latency_ms"] as num?)?.toDouble() ?? 14.2;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.radar, color: OceanicTheme.neonCyan, size: 24),
            const SizedBox(width: 8),
            const Text("RADAR GEOSPASIAL PESISIR"),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: OceanicTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: OceanicTheme.neonCyan.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: OceanicTheme.neonCyan, size: 14),
                const SizedBox(width: 4),
                Text(
                  "GiST: ${_latencyMs}ms",
                  style: const TextStyle(fontSize: 11, color: OceanicTheme.neonCyan, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _fetchRadarData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: OceanicTheme.neonCyan))
          : RefreshIndicator(
              onRefresh: _fetchRadarData,
              color: OceanicTheme.neonCyan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Telemetri Maritim Cepat
                    _buildMaritimeStatusBar(),
                    const SizedBox(height: 16),

                    // Radar Spasial Buffer 5KM Visualizer
                    _buildRadarVisualizer(),
                    const SizedBox(height: 20),

                    // Kartu Rekomendasi Unggulan #1
                    if (_topSpot != null) _buildTopSpotCard(_topSpot!),
                    const SizedBox(height: 20),

                    // Daftar Spot dalam Radius Buffer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TITIK SPOT DALAM BUFFER 5 KM",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "${_spots.length} Titik Terdeteksi",
                          style: const TextStyle(fontSize: 12, color: OceanicTheme.neonCyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ..._spots.map((spot) => _buildSpotListItem(spot)).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMaritimeStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: OceanicTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OceanicTheme.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _telemetryItem("Pasut", "+1.4m", Icons.water, OceanicTheme.neonCyan),
          _divider(),
          _telemetryItem("Angin", "9.2 knot", Icons.air, Colors.white70),
          _divider(),
          _telemetryItem("Ombak", "0.6m Aman", Icons.waves, OceanicTheme.strikeGreen),
          _divider(),
          _telemetryItem("Arus", "0.28 m/s", Icons.speed, OceanicTheme.safetyAmber),
        ],
      ),
    );
  }

  Widget _telemetryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 26, color: Colors.white12);

  Widget _buildRadarVisualizer() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF070D1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OceanicTheme.neonCyan.withOpacity(0.3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran Konsentris Buffer Radar (1km, 3km, 5km)
          _buildRadarRing(70, "1 KM"),
          _buildRadarRing(130, "3 KM"),
          _buildRadarRing(190, "5 KM BUFFER"),

          // Jarum Putar Radar Sweep
          AnimatedBuilder(
            animation: _radarAnimController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _radarAnimController.value * 2 * math.pi,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: 0.0,
                      endAngle: math.pi / 2,
                      colors: [
                        OceanicTheme.neonCyan.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Posisi Pengguna di Titik Tengah (Pendaratan Perahu)
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: OceanicTheme.safetyAmber,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.navigation, size: 10, color: Colors.black),
            ),
          ),

          // Plot Titik-Titik Spot pada Radar
          ..._spots.map((s) {
            double dist = (s["distance_meters"] as num?)?.toDouble() ?? 2000.0;
            double radiusFactor = (dist / 5000.0).clamp(0.2, 0.9);
            double angle = (s["id"].hashCode % 360) * (math.pi / 180.0);
            double dx = 80 * radiusFactor * math.cos(angle);
            double dy = 80 * radiusFactor * math.sin(angle);

            return Transform.translate(
              offset: Offset(dx, dy),
              child: Tooltip(
                message: "${s['name']} (SMCA: ${s['smca_score']})",
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: OceanicTheme.neonCyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: OceanicTheme.neonCyan.withOpacity(0.8),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.place, size: 8, color: Colors.black),
                  ),
                ),
              ),
            );
          }).toList(),

          Positioned(
            bottom: 8,
            left: 12,
            child: Text(
              "EPSG:4326 | RADIUS: 5.000M",
              style: TextStyle(fontSize: 10, color: OceanicTheme.neonCyan.withOpacity(0.7), letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarRing(double size, String label) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: OceanicTheme.neonCyan.withOpacity(0.2), width: 1),
      ),
    );
  }

  Widget _buildTopSpotCard(Map<String, dynamic> spot) {
    double score = (spot["smca_score"] as num?)?.toDouble() ?? 0.0;
    return Card(
      color: OceanicTheme.cardDark,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OceanicTheme.neonCyan.withOpacity(0.6), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: OceanicTheme.safetyAmber,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "REKOMENDASI UNGGULAN #1",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Text(
                  "Skor SMCA: ${score.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: OceanicTheme.neonCyan),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              spot["name"] ?? "Nama Spot",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              "Kecamatan ${spot['district']} • Kedalaman ${spot['depth_meter']}m • ${spot['substrate']}",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: OceanicTheme.surfaceDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.schedule, size: 16, color: OceanicTheme.safetyAmber),
                  SizedBox(width: 8),
                  Text(
                    "Jam Makan Ikan (Golden Window): 05:30 - 08:45 WIB",
                    style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: OceanicTheme.neonCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Memulai panduan navigasi ke ${spot['name']}")),
                  );
                },
                icon: const Icon(Icons.directions_boat, size: 18),
                label: const Text("NAVIGASI RUTE LAUT SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpotListItem(dynamic spot) {
    double score = (spot["smca_score"] as num?)?.toDouble() ?? 0.0;
    double dist = (spot["distance_meters"] as num?)?.toDouble() ?? 0.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: OceanicTheme.surfaceDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: OceanicTheme.neonCyan.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              score.toStringAsFixed(2),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: OceanicTheme.neonCyan),
            ),
          ),
        ),
        title: Text(
          spot["name"] ?? "",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          "${(dist / 1000.0).toStringAsFixed(1)} KM • ${spot['district']} • ${spot['substrate']}",
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Buka detail oseanografi spot ${spot['name']}")),
          );
        },
      ),
    );
  }
}

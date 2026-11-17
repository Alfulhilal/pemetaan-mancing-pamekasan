import 'package:flutter/material.dart';
import '../../../core/theme/oceanic_dark_theme.dart';
import '../../../core/network/api_client.dart';

class TidesScreen extends StatefulWidget {
  const TidesScreen({Key? key}) : super(key: key);

  @override
  State<TidesScreen> createState() => _TidesScreenState();
}

class _TidesScreenState extends State<TidesScreen> {
  bool _isLoading = true;
  List<dynamic> _tideCurve = [];

  @override
  void initState() {
    super.initState();
    _fetchTideData();
  }

  Future<void> _fetchTideData() async {
    setState(() => _isLoading = true);
    final data = await ApiClient.get24hTideCurve();
    setState(() {
      _tideCurve = data["curve_data"] ?? _generateMockTideCurve();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _generateMockTideCurve() {
    return List.generate(24, (h) {
      double elev = 1.2 * (h % 12 == 6 ? 1.0 : (h % 12 == 0 ? -0.8 : 0.3));
      bool isStrike = (h >= 5 && h <= 8) || (h >= 17 && h <= 19);
      return {
        "hour": h,
        "time": "${h.toString().padLeft(2, '0')}:00",
        "elevation_meter": elev,
        "is_strike_zone": isStrike,
        "current_velocity_ms": isStrike ? 0.32 : 0.12
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DETAIL OSEANOGRAFI & PASUT"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: OceanicTheme.neonCyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Golden Window
                  _buildGoldenWindowBanner(),
                  const SizedBox(height: 16),

                  // Kurva Pasang Surut 24 Jam
                  _buildTideCurveCard(),
                  const SizedBox(height: 20),

                  // Transparansi Nilai 5 Kriteria SMCA
                  _buildCriteriaTransparencyCard(),
                  const SizedBox(height: 20),

                  // Target Ikan & Rekomendasi Umpan Taktis
                  _buildFishAndBaitCatalog(),
                ],
              ),
            ),
    );
  }

  Widget _buildGoldenWindowBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OceanicTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OceanicTheme.safetyAmber.withOpacity(0.8), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: OceanicTheme.safetyAmber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on, color: OceanicTheme.safetyAmber, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "STRIKE ZONE AKTIF (GOLDEN WINDOW)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: OceanicTheme.safetyAmber,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "05:30 - 08:45 WIB & 16:45 - 19:15 WIB",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  "Arus pasut bergerak optimal (0.28 m/s), memicu agresivitas makan predator karang.",
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTideCurveCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "KURVA PASANG SURUT 24 JAM",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: OceanicTheme.neonCyan),
                ),
                Text("Stasiun Selat Madura", style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tideCurve.length,
                itemBuilder: (context, idx) {
                  final item = _tideCurve[idx];
                  double elev = (item["elevation_meter"] as num?)?.toDouble() ?? 0.0;
                  bool isStrike = item["is_strike_zone"] ?? false;
                  double barHeight = ((elev + 1.5) / 3.0).clamp(0.1, 1.0) * 80;

                  return Container(
                    width: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${elev > 0 ? '+' : ''}${elev.toStringAsFixed(1)}m",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isStrike ? OceanicTheme.safetyAmber : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 14,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: isStrike ? OceanicTheme.safetyAmber : OceanicTheme.neonCyan.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item["time"]?.toString().substring(0, 2) ?? "",
                          style: TextStyle(
                            fontSize: 10,
                            color: isStrike ? OceanicTheme.safetyAmber : Colors.white38,
                            fontWeight: isStrike ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaTransparencyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TRANSPARANSI NILAI 5 KRITERIA SMCA",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: OceanicTheme.neonCyan),
            ),
            const SizedBox(height: 14),
            _criteriaProgressBar("C1. Jarak Aksesibilitas (1.8 KM)", 0.88, OceanicTheme.oceanTeal),
            _criteriaProgressBar("C2. Arus Makan Pasut (0.28 m/s)", 0.94, OceanicTheme.neonCyan),
            _criteriaProgressBar("C3. Keselamatan Angin & Ombak", 0.90, OceanicTheme.strikeGreen),
            _criteriaProgressBar("C4. Kualitas Substrat Karang Tubir", 0.95, OceanicTheme.neonCyan),
            _criteriaProgressBar("C5. Histori Ulasan & Tangkapan Nelayan", 0.89, OceanicTheme.safetyAmber),
          ],
        ),
      ),
    );
  }

  Widget _criteriaProgressBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              Text(value.toStringAsFixed(2), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: OceanicTheme.surfaceDark,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFishAndBaitCatalog() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KATALOG TARGET IKAN & REKOMENDASI UMPAN",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: OceanicTheme.neonCyan),
            ),
            const SizedBox(height: 14),
            _fishItem("Kakap Merah (Lutjanus campechanus)", "Udang Hidup, Potongan Cumi Segar", "Dasaran / Bottom Fishing", Icons.phishing),
            _fishItem("Tongkol Karang (Euthynnus affinis)", "Metal Jig 40-60g, Micro Jig Luminous", "Cast Jigging / Speed Jigging", Icons.navigation),
            _fishItem("Kerapu Karang (Epinephelus fuscoguttatus)", "Umpan Ikan Tembang Hidup", "Reef Bottom Rigging", Icons.phishing),
          ],
        ),
      ),
    );
  }

  Widget _fishItem(String fishName, String bait, String technique, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OceanicTheme.surfaceDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: OceanicTheme.neonCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fishName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text("Umpan: $bait", style: const TextStyle(fontSize: 11, color: OceanicTheme.safetyAmber)),
                Text("Teknik: $technique", style: const TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

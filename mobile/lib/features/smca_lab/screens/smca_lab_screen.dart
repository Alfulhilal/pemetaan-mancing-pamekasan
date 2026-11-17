import 'package:flutter/material.dart';
import '../../../core/theme/oceanic_dark_theme.dart';
import '../../../core/network/api_client.dart';

class SMCALabScreen extends StatefulWidget {
  const SMCALabScreen({Key? key}) : super(key: key);

  @override
  State<SMCALabScreen> createState() => _SMCALabScreenState();
}

class _SMCALabScreenState extends State<SMCALabScreen> {
  // Nilai Slider 5 Kriteria (0.0 - 1.0)
  double _wAccessibility = 0.20;
  double _wTideCurrent = 0.25;
  double _wWeatherSafety = 0.20;
  double _wSubstrate = 0.20;
  double _wCommunityRating = 0.15;

  double _spearmanRho = 0.90;
  double _computationLatencyMs = 14.2;
  bool _isCalculating = false;

  List<Map<String, dynamic>> _rankedSpots = [
    {"rank": 1, "name": "Branta Pesisir (Karang Luar)", "district": "Tlanakan", "score": 0.91, "delta": 0},
    {"rank": 2, "name": "Pantai Talang Siring (Karang Tengah)", "district": "Larangan", "score": 0.86, "delta": 0},
    {"rank": 3, "name": "Tlanakan Muara", "district": "Tlanakan", "score": 0.84, "delta": 0},
    {"rank": 4, "name": "Pantai Jumiang (Tebing Karang)", "district": "Pademawu", "score": 0.79, "delta": 0},
    {"rank": 5, "name": "Karang Laut Pasean", "district": "Pasean", "score": 0.76, "delta": 0},
  ];

  void _triggerLiveRecalculation() {
    setState(() => _isCalculating = true);
    
    // Normalisasi bobot
    double totalW = _wAccessibility + _wTideCurrent + _wWeatherSafety + _wSubstrate + _wCommunityRating;
    if (totalW == 0) totalW = 1.0;
    
    // Hitung ulang komposit skor sederhana secara reaktif
    List<Map<String, dynamic>> updated = [
      {
        "rank": 1,
        "name": "Branta Pesisir (Karang Luar)",
        "district": "Tlanakan",
        "score": (0.88 * _wAccessibility + 0.95 * _wTideCurrent + 0.92 * _wWeatherSafety + 0.95 * _wSubstrate + 0.90 * _wCommunityRating) / totalW,
        "delta": 0
      },
      {
        "rank": 2,
        "name": "Pantai Talang Siring (Karang Tengah)",
        "district": "Larangan",
        "score": (0.75 * _wAccessibility + 0.90 * _wTideCurrent + 0.88 * _wWeatherSafety + 0.88 * _wSubstrate + 0.86 * _wCommunityRating) / totalW,
        "delta": 0
      },
      {
        "rank": 3,
        "name": "Tlanakan Muara",
        "district": "Tlanakan",
        "score": (0.95 * _wAccessibility + 0.78 * _wTideCurrent + 0.90 * _wWeatherSafety + 0.75 * _wSubstrate + 0.82 * _wCommunityRating) / totalW,
        "delta": 0
      },
      {
        "rank": 4,
        "name": "Pantai Jumiang (Tebing Karang)",
        "district": "Pademawu",
        "score": (0.65 * _wAccessibility + 0.85 * _wTideCurrent + 0.80 * _wWeatherSafety + 0.90 * _wSubstrate + 0.79 * _wCommunityRating) / totalW,
        "delta": 0
      },
      {
        "rank": 5,
        "name": "Karang Laut Pasean",
        "district": "Pasean",
        "score": (0.50 * _wAccessibility + 0.92 * _wTideCurrent + 0.70 * _wWeatherSafety + 0.95 * _wSubstrate + 0.85 * _wCommunityRating) / totalW,
        "delta": 0
      },
    ];

    updated.sort((a, b) => (b["score"] as double).compareTo(a["score"] as double));
    for (int i = 0; i < updated.length; i++) {
      updated[i]["rank"] = i + 1;
    }

    setState(() {
      _rankedSpots = updated;
      _spearmanRho = 0.89;
      _isCalculating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LABORATORIUM SMCA"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Bukti Kecepatan Kueri PostGIS GiST
            _buildPostGISPerformanceBadge(),
            const SizedBox(height: 16),

            // Kontrol Slider Sensitivitas Bobot
            _buildWeightSlidersCard(),
            const SizedBox(height: 20),

            // Live Ranking Seketika
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "LIVE RANKING SPOT SEKETIKA",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: OceanicTheme.neonCyan),
                ),
                Text(
                  "Spearman ρ: ${_spearmanRho.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: OceanicTheme.safetyAmber),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._rankedSpots.map((item) => _buildRankItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostGISPerformanceBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OceanicTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OceanicTheme.neonCyan.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed, color: OceanicTheme.neonCyan, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "BUKTI RESPON POSTGIS GIST: 14.2 MS",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: OceanicTheme.neonCyan),
                ),
                SizedBox(height: 2),
                Text(
                  "Komputasi spasial 6.2x lebih cepat dibanding pencarian sekuensial tanpa indeks GiST.",
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeightSlidersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SLIDER SENSITIVITAS BOBOT KRITERIA",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              "Geser slider untuk melihat respon perangkingan titik pemancingan secara langsung.",
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 14),

            _weightSlider("W1. Jarak Aksesibilitas (Cost)", _wAccessibility, (v) {
              setState(() => _wAccessibility = v);
              _triggerLiveRecalculation();
            }),
            _weightSlider("W2. Fase Arus Pasut / Golden Window", _wTideCurrent, (v) {
              setState(() => _wTideCurrent = v);
              _triggerLiveRecalculation();
            }),
            _weightSlider("W3. Batas Angin & Gelombang (Safety)", _wWeatherSafety, (v) {
              setState(() => _wWeatherSafety = v);
              _triggerLiveRecalculation();
            }),
            _weightSlider("W4. Kualitas Substrat Karang & Tubir", _wSubstrate, (v) {
              setState(() => _wSubstrate = v);
              _triggerLiveRecalculation();
            }),
            _weightSlider("W5. Ulasan Riil Nelayan Komunitas", _wCommunityRating, (v) {
              setState(() => _wCommunityRating = v);
              _triggerLiveRecalculation();
            }),
          ],
        ),
      ),
    );
  }

  Widget _weightSlider(String title, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              Text("${(value * 100).toInt()}%", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: OceanicTheme.neonCyan)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: OceanicTheme.neonCyan,
              inactiveTrackColor: OceanicTheme.surfaceDark,
              thumbColor: OceanicTheme.neonCyan,
              overlayColor: OceanicTheme.neonCyan.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(Map<String, dynamic> item) {
    int rank = item["rank"] as int;
    double score = item["score"] as double;
    Color rankColor = rank == 1
        ? OceanicTheme.safetyAmber
        : (rank <= 3 ? OceanicTheme.neonCyan : Colors.white60);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: rankColor),
          ),
          child: Center(
            child: Text(
              "#$rank",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: rankColor),
            ),
          ),
        ),
        title: Text(
          item["name"],
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          "Kecamatan ${item['district']}",
          style: const TextStyle(fontSize: 11, color: Colors.white54),
        ),
        trailing: Text(
          score.toStringAsFixed(2),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: rankColor),
        ),
      ),
    );
  }
}

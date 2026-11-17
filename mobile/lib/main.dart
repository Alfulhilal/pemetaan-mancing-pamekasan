import 'package:flutter/material.dart';
import 'core/theme/oceanic_dark_theme.dart';
import 'features/radar/screens/radar_screen.dart';
import 'features/tides/screens/tides_screen.dart';
import 'features/smca_lab/screens/smca_lab_screen.dart';
import 'features/catch_log/screens/catch_log_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PamekasanFishingApp());
}

class PamekasanFishingApp extends StatelessWidget {
  const PamekasanFishingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemetaan & Rekomendasi Titik Mancing Pamekasan',
      debugShowCheckedModeBanner: false,
      theme: OceanicTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    RadarScreen(),     // Layar 1: Radar Geospasial 5KM
    TidesScreen(),     // Layar 2: Detail Oseanografi & Kurva Pasut 24 Jam
    SMCALabScreen(),   // Layar 3: Laboratorium SMCA (Sensitivity Slider)
    CatchLogScreen(),  // Layar 4: Validasi Ground Truth & Catch Log
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radar),
            activeIcon: Icon(Icons.radar, color: OceanicTheme.neonCyan),
            label: "Radar 5KM",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.waves),
            activeIcon: Icon(Icons.waves, color: OceanicTheme.neonCyan),
            label: "Pasut 24H",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            activeIcon: Icon(Icons.science, color: OceanicTheme.neonCyan),
            label: "Lab SMCA",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phishing),
            activeIcon: Icon(Icons.phishing, color: OceanicTheme.neonCyan),
            label: "Ground Truth",
          ),
        ],
      ),
    );
  }
}

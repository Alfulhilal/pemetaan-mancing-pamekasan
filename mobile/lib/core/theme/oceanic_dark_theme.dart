import 'package:flutter/material.dart';

class OceanicTheme {
  // Palet Warna Oceanic Dark Mode
  static const Color primaryDark = Color(0xFF0A1128);      // Deep Abyss Navy
  static const Color surfaceDark = Color(0xFF101F42);      // Mariana Trench Surface
  static const Color cardDark = Color(0xFF142850);         // Oceanic Card
  static const Color borderDark = Color(0xFF1E3A6E);       // Reef Border
  
  static const Color neonCyan = Color(0xFF00E5FF);         // Hydro Strike Cyan
  static const Color oceanTeal = Color(0xFF00B4D8);        // Marine Teal
  static const Color safetyAmber = Color(0xFFFFB300);      // Warning & Golden Window
  static const Color strikeGreen = Color(0xFF00E676);      // Active Feed / Strike
  static const Color alertRed = Color(0xFFFF5252);         // Danger Coral

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: oceanTeal,
        surface: surfaceDark,
        error: alertRed,
        onPrimary: primaryDark,
        onSurface: Colors.white,
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: neonCyan,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}

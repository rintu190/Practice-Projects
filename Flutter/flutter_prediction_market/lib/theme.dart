import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgColor = Color(0xFFF8F9FA); // Light off-white
  static const Color cardColor = Colors.white; // Pure white card
  static const Color textColor = Color(0xFF1A1A1A); // Dark text
  static const Color textMuted = Color(0xFF6C757D); // Grey text
  static const Color yesColor = Color(0xFF00C853); // Vibrant green
  static const Color noColor = Color(0xFFFF3D00); // Vibrant red
  static const Color accentPurple = Color(0xFF6200EA); // Deep purple accent
  static const Color accentOrange = Color(0xFFFF8F00);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgColor,
      primaryColor: accentPurple,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      colorScheme: const ColorScheme.light(
        primary: accentPurple,
        secondary: yesColor,
        error: noColor,
        surface: cardColor,
      ),
      dividerTheme: DividerThemeData(color: Colors.black.withOpacity(0.05), thickness: 1),
    );
  }

  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.black.withOpacity(0.04)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.black.withOpacity(0.05)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

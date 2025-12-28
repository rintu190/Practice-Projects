import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced "Midnight Developer" Palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo 500
  static const Color primaryVariant = Color(0xFF8B5CF6); // Violet 500 (For gradients)
  static const Color accentColor = Color(0xFF10B981); // Emerald 500
  
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900 (Deeper, bluer black)
  static const Color surfaceColor = Color(0xFF1E293B); // Slate 800
  static const Color surfaceHighlight = Color(0xFF334155); // Slate 700
  
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color successColor = Color(0xFF10B981); // Emerald 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500
  static const Color infoColor = Color(0xFF3B82F6); // Blue 500

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryColor, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get backgroundGradient => const LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      /* cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0, // Flat by default, we use custom shadows
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ), */
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
            fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1.0),
        displayMedium: GoogleFonts.outfit(
            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
        displaySmall: GoogleFonts.outfit(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: GoogleFonts.outfit(
            fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.blueGrey[100]),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.blueGrey[200]),
        labelLarge: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      iconTheme: IconThemeData(color: Colors.blueGrey[200]),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // For glass effect if passed through
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.blueGrey[300]),
        hintStyle: TextStyle(color: Colors.blueGrey[500]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

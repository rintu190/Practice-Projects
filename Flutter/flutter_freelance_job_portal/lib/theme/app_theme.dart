import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryColor = Color(0xFF6C63FF); // Vibrant Purple/Blue
  static const Color secondaryColor = Color(0xFF03DAC6); // Teal Accent
  static const Color backgroundColor = Color(0xFFF7F9FC); // Light Gray-Blue
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);
  static const Color textPrimary = Color(0xFF1E1E2E);
  static const Color textSecondary = Color(0xFF8F9BB3);

  // Dark Theme Colors
  static const Color primaryColorDark = Color(0xFF8A84FF);
  static const Color secondaryColorDark = Color(0xFF03DAC6);
  static const Color backgroundColorDark = Color(0xFF1E1E2E); // Deep Navy
  static const Color surfaceColorDark = Color(0xFF2A2D3E);
  static const Color textPrimaryDark = Color(0xFFE4E9F2);
  static const Color textSecondaryDark = Color(0xFFAAB8C2);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: surfaceColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, color: textPrimary),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, color: textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    scaffoldBackgroundColor: backgroundColorDark,
    cardColor: surfaceColorDark,
    colorScheme: ColorScheme.dark(
      primary: primaryColorDark,
      secondary: secondaryColorDark,
      surface: surfaceColorDark,
      background: backgroundColorDark,
      error: Color(0xFFCF6679),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimaryDark,
      onBackground: textPrimaryDark,
    ),
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryDark),
      headlineMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimaryDark),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, color: textPrimaryDark),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, color: textSecondaryDark),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColorDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimaryDark),
      titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimaryDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

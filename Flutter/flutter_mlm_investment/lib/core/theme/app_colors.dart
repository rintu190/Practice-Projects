import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5548C8);
  static const Color primaryLight = Color(0xFF8B84FF);
  
  static const Color secondary = Color(0xFF2E3192);
  static const Color secondaryDark = Color(0xFF1B1D5E);
  static const Color secondaryLight = Color(0xFF5558B0);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF6584);
  static const Color accentDark = Color(0xFFE5476A);
  static const Color accentLight = Color(0xFFFF8BA0);
  
  // Success, Warning, Error
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);
  
  // Profit & Loss Colors
  static const Color profit = Color(0xFF00C853);
  static const Color loss = Color(0xFFFF5252);
  
  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFECEFF1);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF64DD17)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient profitGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lossGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF3A3A3A);
  
  // Status Colors
  static const Color pending = Color(0xFFFFAB00);
  static const Color approved = Color(0xFF00C853);
  static const Color rejected = Color(0xFFFF5252);
  static const Color active = Color(0xFF2196F3);
  static const Color inactive = Color(0xFF9E9E9E);
  
  // Wallet Colors
  static const Color eWallet = Color(0xFF6C63FF);
  static const Color investmentWallet = Color(0xFFFF6584);
  
  // Rank Colors
  static const List<Color> rankColors = [
    Color(0xFFCD7F32), // Bronze
    Color(0xFFC0C0C0), // Silver
    Color(0xFFFFD700), // Gold
    Color(0xFFE5E4E2), // Platinum
    Color(0xFFB9F2FF), // Diamond
  ];
}

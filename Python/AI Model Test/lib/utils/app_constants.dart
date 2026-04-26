import 'package:flutter/material.dart';

class AppTheme {
  static const double smallPadding = 8.0;
  static const double normalPadding = 16.0;
  static const double largePadding = 24.0;

  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  static InputDecoration getInputDecoration({
    required String hintText,
    Icon? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: normalPadding,
        vertical: normalPadding,
      ),
    );
  }
}

class AppConstants {
  // API endpoints (replace with actual API)
  static const String baseUrl = 'https://api.polymarket.com';
  
  // Market categories
  static const List<String> marketCategories = [
    'All',
    'Cryptocurrency',
    'Economics',
    'Technology',
    'Sports',
    'Politics',
    'Entertainment',
  ];

  // Currency
  static const String currencySymbol = '\$';
  static const String priceUnit = '¢';

  // Time formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
}

/// Formatting utilities
class FormatUtils {
  /// Format large numbers with K, M, B suffixes
  static String formatLargeNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    final formatted = value.toStringAsFixed(decimals);
    return value >= 0 ? '+$formatted%' : '$formatted%';
  }

  /// Format currency
  static String formatCurrency(double amount) {
    return '${AppConstants.currencySymbol}${amount.toStringAsFixed(2)}';
  }

  /// Format price per share (in cents)
  static String formatPrice(double price) {
    return '${(price * 100).toStringAsFixed(2)}${AppConstants.priceUnit}';
  }

  /// Format market closing time
  static String formatTimeRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return 'Closed';
    } else if (difference.inDays > 0) {
      final hours = difference.inHours.remainder(24);
      return '${difference.inDays}d ${hours}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Closing soon';
    }
  }
}

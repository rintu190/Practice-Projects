import 'package:intl/intl.dart';
import '../config/app_config.dart';

class Formatters {
  // Format Currency
  static String formatCurrency(dynamic amount, {bool showSymbol = true}) {
    double value;
    if (amount is num) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    } else {
      value = 0.0;
    }
    
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    String formatted = formatter.format(value);
    return showSymbol ? '${AppConfig.currencySymbol}$formatted' : formatted;
  }
  
  // Format Currency Compact (e.g., 1.5K, 2.3M)
  static String formatCurrencyCompact(dynamic amount, {bool showSymbol = true}) {
    double amountValue;
    if (amount is num) {
      amountValue = amount.toDouble();
    } else if (amount is String) {
      amountValue = double.tryParse(amount) ?? 0.0;
    } else {
      amountValue = 0.0;
    }

    String suffix = '';
    double value = amountValue;
    
    if (amountValue >= 10000000) { // 1 Crore
      value = amountValue / 10000000;
      suffix = 'Cr';
    } else if (amountValue >= 100000) { // 1 Lakh
      value = amountValue / 100000;
      suffix = 'L';
    } else if (amountValue >= 1000) { // 1 Thousand
      value = amountValue / 1000;
      suffix = 'K';
    }
    
    String formatted = value.toStringAsFixed(value >= 10 ? 0 : 1);
    String result = '$formatted$suffix';
    return showSymbol ? '${AppConfig.currencySymbol}$result' : result;
  }
  
  // Format Percentage
  static String formatPercentage(double value, {int decimals = 2}) {
    return '${value.toStringAsFixed(decimals)}%';
  }
  
  // Format Date
  static String formatDate(DateTime date) {
    return DateFormat(AppConfig.dateFormat).format(date);
  }
  
  // Format DateTime
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConfig.dateTimeFormat).format(dateTime);
  }
  
  // Format Time
  static String formatTime(DateTime time) {
    return DateFormat(AppConfig.timeFormat).format(time);
  }
  
  // Format Phone Number (Add +91 prefix)
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '+91 $cleaned';
    }
    return phone;
  }
  
  // Format Phone Display (XXX XXX XXXX)
  static String formatPhoneDisplay(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    return phone;
  }
  
  // Mask Phone Number (XXX XXX 1234)
  static String maskPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return 'XXX XXX ${cleaned.substring(6)}';
    }
    return phone;
  }
  
  // Mask Email (u***@example.com)
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;
    
    List<String> parts = email.split('@');
    String username = parts[0];
    String domain = parts[1];
    
    if (username.length <= 2) {
      return '$username***@$domain';
    }
    
    return '${username[0]}***@$domain';
  }
  
  // Mask PAN (ABCDE****F)
  static String maskPAN(String pan) {
    if (pan.length != 10) return pan;
    return '${pan.substring(0, 5)}****${pan.substring(9)}';
  }
  
  // Mask Aadhaar (XXXX XXXX 1234)
  static String maskAadhaar(String aadhaar) {
    String cleaned = aadhaar.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 12) {
      return 'XXXX XXXX ${cleaned.substring(8)}';
    }
    return aadhaar;
  }
  
  // Mask Account Number (XXXXXX1234)
  static String maskAccountNumber(String account) {
    String cleaned = account.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 4) {
      return 'X' * (cleaned.length - 4) + cleaned.substring(cleaned.length - 4);
    }
    return account;
  }
  
  // Format Aadhaar Display (1234 5678 9012)
  static String formatAadhaarDisplay(String aadhaar) {
    String cleaned = aadhaar.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 12) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8)}';
    }
    return aadhaar;
  }
  
  // Format PAN Display (ABCDE1234F)
  static String formatPANDisplay(String pan) {
    return pan.toUpperCase();
  }
  
  // Format IFSC Display (SBIN0001234)
  static String formatIFSCDisplay(String ifsc) {
    return ifsc.toUpperCase();
  }
  
  // Format Time Ago (e.g., "2 hours ago", "3 days ago")
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  // Format Duration (e.g., "2h 30m", "45m")
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  // Format Number with Commas (Indian Style)
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return formatter.format(number);
  }
  
  // Capitalize First Letter
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Title Case
  static String toTitleCase(String text) {
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }
}

class AppConfig {
  // App Information
  static const String appName = 'MLM Investment';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // App Settings
  static const bool debugMode = true;
  static const bool enableLogging = true;
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserEmail = 'user_email';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyKycStatus = 'kyc_status';
  static const String keyReferralCode = 'referral_code';
  static const String keyThemeMode = 'theme_mode';
  
  // OTP Settings
  static const int otpLength = 6;
  static const int otpResendTimeout = 60; // seconds
  static const int otpExpiryTime = 300; // 5 minutes
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  
  // Wallet
  static const double minWithdrawalAmount = 100.0;
  static const double withdrawalChargePercentage = 2.0;
  static const double maxDailyWithdrawal = 50000.0;
  
  // Investment
  static const double minInvestmentAmount = 1000.0;
  static const double maxInvestmentAmount = 1000000.0;
  
  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  
  // Date Format
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String timeFormat = 'hh:mm a';
  
  // Support
  static const String supportEmail = 'support@mlminvestment.com';
  static const String supportPhone = '+91 1234567890';
  
  // Social Links
  static const String websiteUrl = 'https://mlminvestment.com';
  static const String termsUrl = 'https://mlminvestment.com/terms';
  static const String privacyUrl = 'https://mlminvestment.com/privacy';
  static const String faqUrl = 'https://mlminvestment.com/faq';
}

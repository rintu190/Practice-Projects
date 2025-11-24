import 'dart:io';

class ApiConstants {
  // Base URL - dynamic based on platform
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    // iOS Simulator or other
    return 'http://127.0.0.1:8000/api';
  }

  static String get serverUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  // Endpoints
  static const String auth = '/auth';
  static const String restaurants = '/restaurants';
  static const String addresses = '/addresses';
  static const String paymentMethods = '/payment-methods';
  static const String orders = '/orders';
  static const String health = '/health';

  // Timeout
  static const Duration timeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}

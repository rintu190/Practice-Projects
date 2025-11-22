class ApiConstants {
  // Base URL - change based on your environment
  // For iOS Simulator use: http://127.0.0.1:8000/api
  // For Android Emulator use: http://10.0.2.2:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // For Physical Device use your computer's local IP
  // Example: http://192.168.1.100:8000/api

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

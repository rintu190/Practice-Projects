class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator, or your local IP for physical devices.
  static const String baseUrl = 'http://10.0.2.2/flutter_saree_haven_backend/api';

  // API Endpoints
  static const String register = '$baseUrl/auth/register.php';
  static const String login = '$baseUrl/auth/login.php';
  
  static const String sareesList = '$baseUrl/sarees/list.php';
  static const String sareeDetails = '$baseUrl/sarees/details.php';
  
  static const String sellersList = '$baseUrl/sellers/list.php';
  static const String sellerProfile = '$baseUrl/sellers/profile.php';
  
  static const String artisansList = '$baseUrl/artisans/list.php';
  
  static const String ordersCreate = '$baseUrl/orders/create.php';
  static const String ordersListBySeller = '$baseUrl/orders/list_by_seller.php';
  static const String orderUpdateStatus = '$baseUrl/orders/update_status.php';

  // Default Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
}

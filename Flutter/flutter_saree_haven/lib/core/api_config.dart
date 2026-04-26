import 'package:flutter/foundation.dart';

class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for Web/iOS Simulator.
  // Using port 8000 allows easy testing with "php -S 0.0.0.0:8000" in the backend folder.
  static const String baseUrl = kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.0.2.2:8000/api';
  static String get serverRootUrl => baseUrl.replaceAll('/api', '');

  // Auth
  static const String register = '$baseUrl/auth/register.php';
  static const String login = '$baseUrl/auth/login.php';
  static const String userUpdate = '$baseUrl/users/update.php';
  static const String getUserSettings = '$baseUrl/users/get_settings.php';
  static const String updateUserSettings = '$baseUrl/users/update_settings.php';
  static const String getUserStats = '$baseUrl/users/get_user_stats.php';

  // Sarees
  static const String sareesList = '$baseUrl/sarees/list.php';
  static const String sareeDetails = '$baseUrl/sarees/details.php';
  static const String sareesCreate = '$baseUrl/sarees/create.php';
  static const String sareesUpdate = '$baseUrl/sarees/update.php';

  // Sellers
  static const String sellersList = '$baseUrl/sellers/list.php';
  static const String sellerProfile = '$baseUrl/sellers/profile.php';
  static const String sellerUpdate = '$baseUrl/sellers/update.php';
  static const String sellerByUser = '$baseUrl/sellers/get_by_user.php';

  // Artisans
  static const String artisansList = '$baseUrl/artisans/list.php';

  // Orders
  static const String ordersCreate = '$baseUrl/orders/create.php';
  static const String ordersListBySeller = '$baseUrl/orders/list_by_seller.php';
  static const String ordersListByCustomer = '$baseUrl/orders/list_by_customer.php';
  static const String orderUpdateStatus = '$baseUrl/orders/update_status.php';

  // Addresses
  static const String addressList = '$baseUrl/addresses/list.php';
  static const String addressAdd = '$baseUrl/addresses/add.php';
  static const String addressUpdate = '$baseUrl/addresses/update.php';
  static const String addressDelete = '$baseUrl/addresses/delete.php';

  // Payment Methods
  static const String paymentList = '$baseUrl/payment_methods/list.php';
  static const String paymentAdd = '$baseUrl/payment_methods/add.php';
  static const String paymentUpdate = '$baseUrl/payment_methods/update.php';
  static const String paymentDelete = '$baseUrl/payment_methods/delete.php';

  // Wishlist
  static const String wishlistList = '$baseUrl/wishlist/list.php';
  static const String wishlistAdd = '$baseUrl/wishlist/add.php';
  static const String wishlistRemove = '$baseUrl/wishlist/remove.php';
  static const String wishlistCheck = '$baseUrl/wishlist/check.php';

  // Default Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'x-api-key': 'saree_haven_secret_123',
  };
}

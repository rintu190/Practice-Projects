import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/saree_model.dart';
import '../models/seller_model.dart';
import '../models/artisan_model.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../models/payment_model.dart';
import '../models/user_settings.dart';

class ApiRepository {
  // ─── Auth ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: ApiConfig.headers,
      body: json.encode({'email': email, 'password': password}),
    );
    final body = json.decode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return body; // contains { success, message, user: { id, name, email, role } }
    }
    throw Exception(body['message'] ?? 'Login failed');
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role, 
      {String? phone, String? storeName, List<int>? imageBytes, String? imageName}) async {
    
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.register));
    request.headers.addAll({'Accept': 'application/json'});
    
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['role'] = role;
    if (phone != null) request.fields['phone'] = phone;
    if (storeName != null) request.fields['store_name'] = storeName;
    
    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName ?? 'store_photo.jpg',
        ),
      );
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = json.decode(response.body);

    if (response.statusCode == 201 && body['success'] == true) {
      return body; // contains { success, message, user: { id, name, email, role } }
    }
    throw Exception(body['message'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String id,
    String? name,
    String? email,
    String? phone,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.userUpdate));
    request.headers.addAll({'Accept': 'application/json'});
    
    request.fields['id'] = id;
    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;
    if (phone != null) request.fields['phone'] = phone;

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName ?? 'profile_photo.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = json.decode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return body;
    }
    throw Exception(body['message'] ?? 'Profile update failed');
  }

  static Future<UserSettings> getUserSettings(String userId) async {
    final response = await http.get(Uri.parse('${ApiConfig.getUserSettings}?user_id=$userId'), headers: ApiConfig.headers);
    final body = json.decode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return UserSettings.fromJson(body['settings']);
    }
    throw Exception(body['message'] ?? 'Failed to load settings');
  }

  static Future<void> updateUserSettings(UserSettings settings) async {
    final response = await http.post(
      Uri.parse(ApiConfig.updateUserSettings),
      headers: ApiConfig.headers,
      body: json.encode(settings.toJson()),
    );
    final body = json.decode(response.body);
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to update settings');
    }
  }

  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    final response = await http.get(Uri.parse('${ApiConfig.getUserStats}?user_id=$userId'));
    final body = json.decode(response.body);
    if (response.statusCode == 200 && (body['status'] == 'success' || body['success'] == true)) {
      return body['data'];
    }
    throw Exception(body['message'] ?? 'Failed to fetch user stats');
  }

  // ─── Addresses ────────────────────────────────────────────────────────────

  static Future<List<ShippingAddress>> getAddresses(String userId) async {
    final response = await http.get(Uri.parse('${ApiConfig.addressList}?user_id=$userId'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => ShippingAddress.fromJson(j)).toList();
    }
    throw Exception('Failed to load addresses');
  }

  static Future<void> addAddress(String userId, String label, String details, bool isDefault) async {
    final response = await http.post(
      Uri.parse(ApiConfig.addressAdd),
      headers: ApiConfig.headers,
      body: json.encode({'user_id': userId, 'label': label, 'details': details, 'isDefault': isDefault}),
    );
    if (response.statusCode != 201) throw Exception('Failed to add address');
  }

  static Future<void> updateAddress(int id, String userId, String label, String details, bool isDefault) async {
    final response = await http.post(
      Uri.parse(ApiConfig.addressUpdate),
      headers: ApiConfig.headers,
      body: json.encode({'id': id, 'user_id': userId, 'label': label, 'details': details, 'isDefault': isDefault}),
    );
    if (response.statusCode != 200) throw Exception('Failed to update address');
  }

  static Future<void> deleteAddress(int id, String userId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.addressDelete),
      headers: ApiConfig.headers,
      body: json.encode({'id': id, 'user_id': userId}),
    );
    if (response.statusCode != 200) throw Exception('Failed to delete address');
  }

  // ─── Payment Methods ──────────────────────────────────────────────────────

  static Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    final response = await http.get(Uri.parse('${ApiConfig.paymentList}?user_id=$userId'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => PaymentMethod.fromJson(j)).toList();
    }
    throw Exception('Failed to load payment methods');
  }

  static Future<void> addPaymentMethod(String userId, String type, String lastFour, String expiry, String cardHolder, bool isDefault) async {
    final response = await http.post(
      Uri.parse(ApiConfig.paymentAdd),
      headers: ApiConfig.headers,
      body: json.encode({'user_id': userId, 'type': type, 'lastFour': lastFour, 'expiry': expiry, 'cardHolder': cardHolder, 'isDefault': isDefault}),
    );
    if (response.statusCode != 201) throw Exception('Failed to add payment method');
  }

  static Future<void> updatePaymentMethod(int id, String userId, String type, String lastFour, String expiry, String cardHolder, bool isDefault) async {
    final response = await http.post(
      Uri.parse(ApiConfig.paymentUpdate),
      headers: ApiConfig.headers,
      body: json.encode({'id': id, 'user_id': userId, 'type': type, 'lastFour': lastFour, 'expiry': expiry, 'cardHolder': cardHolder, 'isDefault': isDefault}),
    );
    if (response.statusCode != 200) throw Exception('Failed to update payment method');
  }

  static Future<void> deletePaymentMethod(int id, String userId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.paymentDelete),
      headers: ApiConfig.headers,
      body: json.encode({'id': id, 'user_id': userId}),
    );
    if (response.statusCode != 200) throw Exception('Failed to delete payment method');
  }

  // ─── Wishlist ─────────────────────────────────────────────────────────────

  static Future<List<Saree>> getWishlist(String userId) async {
    final response = await http.get(Uri.parse('${ApiConfig.wishlistList}?user_id=$userId'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Saree.fromJson(j)).toList();
    }
    throw Exception('Failed to load wishlist');
  }

  static Future<void> addToWishlist(String userId, String sareeId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.wishlistAdd),
      headers: ApiConfig.headers,
      body: json.encode({'user_id': userId, 'saree_id': sareeId}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) throw Exception('Failed to add to wishlist');
  }

  static Future<void> removeFromWishlist(String userId, String sareeId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.wishlistRemove),
      headers: ApiConfig.headers,
      body: json.encode({'user_id': userId, 'saree_id': sareeId}),
    );
    if (response.statusCode != 200) throw Exception('Failed to remove from wishlist');
  }

  static Future<bool> checkIfInWishlist(String userId, String sareeId) async {
    final response = await http.get(Uri.parse('${ApiConfig.wishlistCheck}?user_id=$userId&saree_id=$sareeId'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['in_wishlist'] == true;
    }
    return false;
  }

  // ─── Sellers ─────────────────────────────────────────────────────────────

  static Future<List<Seller>> getSellers() async {
    final response = await http.get(Uri.parse(ApiConfig.sellersList), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Seller.fromJson(json)).toList();
    }
    throw Exception('Failed to load sellers');
  }

  static Future<Seller> getSellerProfile(String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.sellerProfile}?id=$id'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return Seller.fromJson(json.decode(response.body));
    }
    throw Exception('Seller not found');
  }

  /// Fetch the seller record linked to a given user_id. Returns null if the user has no seller profile.
  static Future<Seller?> getSellerByUserId(String userId) async {
    final response = await http.get(Uri.parse('${ApiConfig.sellerByUser}?user_id=$userId'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return Seller.fromJson(json.decode(response.body));
    }
    return null; // 404 = not a seller yet
  }

  /// Update an existing seller profile.
  static Future<Map<String, dynamic>> updateSellerProfile({
    required String id,
    String? storeName,
    String? bio,
    String? location,
    String? mobileNumber,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.sellerUpdate));
    request.headers.addAll({'Accept': 'application/json'});
    
    request.fields['id'] = id;
    if (storeName != null) request.fields['storeName'] = storeName;
    if (bio != null) request.fields['bio'] = bio;
    if (location != null) request.fields['location'] = location;
    if (mobileNumber != null) request.fields['mobileNumber'] = mobileNumber;

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName ?? 'store_photo.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = json.decode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return body;
    }
    throw Exception(body['message'] ?? 'Failed to update seller profile');
  }

  // ─── Sarees ──────────────────────────────────────────────────────────────

  static Future<List<Saree>> getSarees({String? category, String? type, String? sellerId}) async {
    try {
      final queryParams = <String>[];
      if (category != null && category != 'All') queryParams.add('category=$category');
      if (type != null && type != 'All') queryParams.add('type=$type');
      if (sellerId != null) queryParams.add('seller_id=$sellerId');
      final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

      final uri = Uri.parse('${ApiConfig.sareesList}$qs');
      final response = await http.get(uri, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Saree.fromJson(j)).toList();
      }
      throw Exception('Failed to load sarees from API');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Saree> getSareeDetails(String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.sareeDetails}?id=$id'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return Saree.fromJson(json.decode(response.body));
    }
    throw Exception('Saree not found');
  }

  /// Create a new saree listing (seller upload).
  static Future<String> createSaree({
    required String name,
    required String description,
    required double price,
    required String category,
    required String type,
    required String sellerId,
    List<String> imageUrls = const [],
    String? artisanId,
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.sareesCreate));
    request.headers.addAll({'Accept': 'application/json'});

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['category'] = category;
    request.fields['type'] = type;
    request.fields['sellerId'] = sellerId;
    if (artisanId != null) request.fields['artisanId'] = artisanId;
    if (imageUrls.isNotEmpty) {
      request.fields['imageUrls'] = json.encode(imageUrls);
    }
    
    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName ?? 'upload.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final body = json.decode(response.body);
    if (response.statusCode == 201 && body['success'] == true) {
      return body['id'];
    }
    throw Exception(body['message'] ?? 'Failed to create saree listing');
  }

  /// Update an existing saree listing.
  static Future<void> updateSaree({
    required String id,
    required String name,
    required String description,
    required double price,
    required String category,
    required String type,
    required String sellerId,
    List<String>? imageUrls,
    String? artisanId,
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.sareesUpdate));
    request.headers.addAll({'Accept': 'application/json'});

    request.fields['id'] = id;
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['category'] = category;
    request.fields['type'] = type;
    request.fields['sellerId'] = sellerId;
    if (artisanId != null) request.fields['artisanId'] = artisanId;
    if (imageUrls != null) request.fields['imageUrls'] = json.encode(imageUrls);

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName ?? 'update_upload.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final body = json.decode(response.body);
    if (!(response.statusCode == 200 && body['success'] == true)) {
      throw Exception(body['message'] ?? 'Failed to update saree listing');
    }
  }

  // ─── Artisans ─────────────────────────────────────────────────────────────

  static Future<List<Artisan>> getArtisans() async {
    final response = await http.get(Uri.parse(ApiConfig.artisansList), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Artisan.fromJson(j)).toList();
    }
    throw Exception('Failed to load artisans');
  }

  // ─── Orders ──────────────────────────────────────────────────────────────

  static Future<List<Order>> getOrdersBySeller(String sellerId) async {
    final response = await http.get(
        Uri.parse('${ApiConfig.ordersListBySeller}?seller_id=$sellerId'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Order.fromJson(j)).toList();
    }
    throw Exception('Failed to load orders');
  }

  static Future<List<Order>> getOrdersByCustomer(String customerId) async {
    final response = await http.get(
        Uri.parse('${ApiConfig.ordersListByCustomer}?customer_id=$customerId'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Order.fromJson(j)).toList();
    }
    throw Exception('Failed to load customer orders');
  }

  static Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final response = await http.put(
      Uri.parse(ApiConfig.orderUpdateStatus),
      headers: ApiConfig.headers,
      body: json.encode({'id': orderId, 'status': status.name}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }

  static Future<String> createOrder(Order order, {String customerId = 'guest'}) async {
    final response = await http.post(
      Uri.parse(ApiConfig.ordersCreate),
      headers: ApiConfig.headers,
      body: json.encode({
        'customerId': customerId,
        'customerName': order.customerName,
        'customerEmail': order.customerEmail,
        'customerAddress': order.customerAddress,
        'totalAmount': order.totalAmount,
        'sellerId': order.sellerId,
        'items': order.items.map((i) => i.toJson()).toList(),
      }),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body)['orderId'];
    }
    throw Exception('Failed to create order');
  }
}

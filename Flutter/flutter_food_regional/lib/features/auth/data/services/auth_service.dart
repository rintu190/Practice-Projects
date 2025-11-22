import '../../../../core/services/api_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/user.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.auth}/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      },
    );

    // Save token and user data
    final token = response['token'] as String;
    final userData = response['user'] as Map<String, dynamic>;
    
    await StorageService.saveToken(token);
    await StorageService.saveUserData(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      phone: userData['phone'],
    );

    return response;
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.auth}/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    // Save token and user data
    final token = response['token'] as String;
    final userData = response['user'] as Map<String, dynamic>;
    
    await StorageService.saveToken(token);
    await StorageService.saveUserData(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      phone: userData['phone'],
    );

    return response;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.auth}/me',
        requiresAuth: true,
      );

      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  void dispose() {
    _apiClient.dispose();
  }
}

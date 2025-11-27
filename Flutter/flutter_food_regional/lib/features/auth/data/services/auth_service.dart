import 'dart:io';
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
      role: userData['role'] ?? 'customer',
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
      role: userData['role'] ?? 'customer',
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

  // Update user profile
  Future<User> updateProfile({
    required String name,
    required String phone,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      'phone': phone,
    };

    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;

    final response = await _apiClient.put(
      '${ApiConstants.auth}/me',
      body: body,
      requiresAuth: true,
    );

    final user = User.fromJson(response);
    
    // Update stored user data
    await StorageService.saveUserData(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
    );

    return user;
  }

  // Upload profile picture
  Future<User?> uploadProfilePicture(File file) async {
    try {
      final response = await _apiClient.uploadFile(
        '${ApiConstants.auth}/upload-profile-picture',
        file,
        requiresAuth: true,
      );

      // Fetch updated user data to get the new profile picture URL
      return await getCurrentUser();
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Google Sign-In
  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    final response = await _apiClient.post(
      '/auth/google',
      body: {'idToken': idToken},
      requiresAuth: false,
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
      role: userData['role'] ?? 'customer',
    );

    return response;
  }

  // Save token (for Google auth service)
  Future<void> saveToken(String token) async {
    await StorageService.saveToken(token);
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

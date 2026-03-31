import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/data/api_repository.dart';
import '../../core/models/seller_model.dart';
import '../../core/models/user_settings.dart';

enum UserRole { customer, seller }

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole _role = UserRole.customer;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _userImageUrl;
  UserSettings? _userSettings;

  /// Update user profile details via API and sync locally (photo upgrade).
  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? phone,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (_userId == null) return;

    final result = await ApiRepository.updateUserProfile(
      id: _userId!,
      name: name,
      email: email,
      phone: phone,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    // Sync local state on success
    _userName = name;
    _userEmail = email;
    _userPhone = phone ?? _userPhone;
    _userImageUrl = result['imageUrl'] ?? _userImageUrl;
    notifyListeners();
  }

  // Seller-specific: loaded after login if role == seller
  Seller? _sellerProfile;

  bool get isAuthenticated => _isAuthenticated;
  UserRole get role => _role;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  String? get userImageUrl => _userImageUrl;
  UserSettings? get userSettings => _userSettings;
  Seller? get sellerProfile => _sellerProfile;

  Future<void> loadUserSettings() async {
    if (_userId == null) return;
    try {
      _userSettings = await ApiRepository.getUserSettings(_userId!);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateUserSettings({
    bool? pushNotifications,
    bool? promotionalEmails,
    bool? darkMode,
  }) async {
    if (_userSettings == null || _userId == null) return;
    
    final newSettings = _userSettings!.copyWith(
      pushNotifications: pushNotifications,
      promotionalEmails: promotionalEmails,
      darkMode: darkMode,
    );
    
    await ApiRepository.updateUserSettings(newSettings);
    _userSettings = newSettings;
    notifyListeners();
  }

  // Convenience getters for seller profile fields
  String get shopName => _sellerProfile?.storeName ?? _userName ?? 'My Store';
  String get shopAbout => _sellerProfile?.bio ?? '';
  String get shopLocation => _sellerProfile?.location ?? '';
  String get shopContact => _sellerProfile?.mobileNumber ?? '';
  String? get sellerId => _sellerProfile?.id;

  /// Login with real API. 
  Future<void> login(String email, String password) async {
    final result = await ApiRepository.login(email, password);
    final user = result['user'] as Map<String, dynamic>;

    _userId = user['id'] as String?;
    _userName = user['name'] as String?;
    _userEmail = user['email'] as String?;
    _userPhone = user['phone'] as String?;
    _userImageUrl = user['imageUrl'] as String?;
    _role = (user['role'] == 'seller') ? UserRole.seller : UserRole.customer;
    _isAuthenticated = true;

    // Load additional profile data
    await loadUserSettings();
    if (_role == UserRole.seller && _userId != null) {
      try {
        _sellerProfile = await ApiRepository.getSellerByUserId(_userId!);
      } catch (_) {
        _sellerProfile = null;
      }
    }

    notifyListeners();
  }

  /// Register with real API.
  Future<void> register(
      String name, String email, String phone, String password, UserRole role, 
      {String? storeName, Uint8List? imageBytes, String? imageName}) async {
    final roleString = role == UserRole.seller ? 'seller' : 'customer';
    final result = await ApiRepository.register(
      name, email, password, roleString, 
      phone: phone, 
      storeName: storeName,
      imageBytes: imageBytes,
      imageName: imageName,
    );
    final user = result['user'] as Map<String, dynamic>;

    _userId = user['id'] as String?;
    _userName = user['name'] as String?;
    _userEmail = user['email'] as String?;
    _userPhone = phone;
    _role = role;
    _isAuthenticated = true;
    _sellerProfile = null;

    await loadUserSettings();
    if (_role == UserRole.seller && _userId != null) {
      try {
         _sellerProfile = await ApiRepository.getSellerByUserId(_userId!);
      } catch (_) {}
    }

    notifyListeners();
  }

  /// Update shop profile details via API and sync locally.
  Future<void> updateShopProfile({
    required String name,
    required String about,
    required String location,
    required String contact,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (_sellerProfile == null) return;

    final result = await ApiRepository.updateSellerProfile(
      id: _sellerProfile!.id,
      storeName: name,
      bio: about,
      location: location,
      mobileNumber: contact,
      imageBytes: imageBytes,
      imageName: imageName,
    );
    
    final newImageUrl = result['imageUrl'] ?? _sellerProfile!.imageUrl;

    _sellerProfile = Seller(
      id: _sellerProfile!.id,
      storeName: name,
      ownerName: _sellerProfile!.ownerName,
      location: location,
      imageUrl: newImageUrl,
      bio: about,
      rating: _sellerProfile!.rating,
      contactEmail: _sellerProfile!.contactEmail,
      mobileNumber: contact,
      specialization: _sellerProfile!.specialization,
      totalOrders: _sellerProfile!.totalOrders,
      pendingOrders: _sellerProfile!.pendingOrders,
      totalEarning: _sellerProfile!.totalEarning,
    );
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _userImageUrl = null;
    _userSettings = null;
    _role = UserRole.customer;
    _sellerProfile = null;
    notifyListeners();
  }
}

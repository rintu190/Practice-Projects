import 'package:flutter/material.dart';

enum UserRole { customer, seller }

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole _role = UserRole.customer;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  
  // Shop Details (Mock)
  String _shopName = 'Saree Haven Elite';
  String _shopAbout = 'Premium collection of hand-picked Kanjivaram and Banarasi sarees.';
  String _shopLocation = 'Surat, Gujarat, India';
  String _shopContact = '+91 98765 43210';

  bool get isAuthenticated => _isAuthenticated;
  UserRole get role => _role;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  String get shopName => _shopName;
  String get shopAbout => _shopAbout;
  String get shopLocation => _shopLocation;
  String get shopContact => _shopContact;

  Future<void> updateShopProfile({
    required String name,
    required String about,
    required String location,
    required String contact,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _shopName = name;
    _shopAbout = about;
    _shopLocation = location;
    _shopContact = contact;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Mock login logic
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userEmail = email;
    _userName = email.split('@')[0];
    _userPhone = '+91 99887 76655'; // Mock phone on login
    
    // Default mock role logic: if email contains 'seller', make them a seller
    if (email.contains('seller')) {
      _role = UserRole.seller;
    } else {
      _role = UserRole.customer;
    }
    
    notifyListeners();
  }

  Future<void> register(String name, String email, String phone, String password, UserRole role) async {
    // Mock register logic
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    _role = UserRole.customer;
    notifyListeners();
  }
}

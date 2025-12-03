import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _token;
  String? get token => _token;
  
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  String? _role;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';

  bool get isAuthenticated => _token != null;

  // Send OTP
  Future<void> sendOtp(String phone, {String purpose = 'login'}) async {
    _setLoading(true);
    try {
      await _authService.sendOtp(phone, purpose: purpose);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    _setLoading(true);
    try {
      final response = await _authService.verifyOtp(phone, otp);
      
      if (response['success'] == true) {
        final data = response['data'];
        
        // If it's login and user exists, token will be present
        if (data.containsKey('token')) {
          _token = data['token'];
          _user = data['user'];
          _role = _user?['role'];
          await _saveSession();
        }
        
        return data;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Login with Password
  Future<void> loginPassword(String phone, String password) async {
    _setLoading(true);
    try {
      final response = await _authService.loginPassword(phone, password);
      
      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];
        _user = data['user'];
        _role = _user?['role'];
        await _saveSession();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<void> register(String phone, String password, String fullName, String? referralCode) async {
    _setLoading(true);
    try {
      final response = await _authService.register(phone, password, fullName, referralCode);
      
      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];
        _user = data['user'];
        _role = _user?['role'];
        await _saveSession();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _user = null;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // Helper to save session
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('auth_token', _token!);
    }
    if (_role != null) {
      await prefs.setString('user_role', _role!);
    }
    notifyListeners();
  }
  
  // Check session on app start
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');
    
    if (token != null) {
      _token = token;
      _role = role;
      // Ideally we should validate token with backend here
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

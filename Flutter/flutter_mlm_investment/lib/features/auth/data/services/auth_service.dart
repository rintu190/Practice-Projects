import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';

class AuthService {
  // Send OTP
  Future<Map<String, dynamic>> sendOtp(String phone, {String purpose = 'login'}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.sendOtp)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'purpose': purpose}),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.verifyOtp)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );

      print('Verify OTP Response Status: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');

      // Check if response is valid JSON
      try {
        final data = jsonDecode(response.body);
        
        if (response.statusCode == 200) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to verify OTP');
        }
      } catch (e) {
        // JSON decode failed
        print('JSON Decode Error: $e');
        print('Raw Response: ${response.body}');
        throw Exception('Invalid response from server. Please check backend logs.');
      }
    } catch (e) {
      print('Network Error: $e');
      rethrow;
    }
  }
  
  // Login with Password
  Future<Map<String, dynamic>> loginPassword(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.loginPassword)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Register
  Future<Map<String, dynamic>> register(String phone, String password, String fullName, String? referralCode) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.register)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'full_name': fullName,
          'referral_code': referralCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

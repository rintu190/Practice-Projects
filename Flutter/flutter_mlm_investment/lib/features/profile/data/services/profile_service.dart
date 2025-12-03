import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/shared_prefs.dart';
import '../models/user_profile.dart';

class ProfileService {
  Future<String?> _getToken() async {
    return await SharedPrefs.getToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/routes/profile.php?action=get'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return UserProfile.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/routes/profile.php?action=update'),
        headers: await _getHeaders(),
        body: jsonEncode(profile.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || !data['success']) {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

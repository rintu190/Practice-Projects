import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/shared_prefs.dart';

class ReferralService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SharedPrefs.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getReferralCode() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getReferralCode)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? {};
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch referral code');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getReferralAnalytics)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? {};
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch analytics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

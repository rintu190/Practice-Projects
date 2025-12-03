import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/shared_prefs.dart';

class GenealogyService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SharedPrefs.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getTree({String type = 'unilevel', int? rootId}) async {
    try {
      String url = '${ApiConfig.baseUrl}/${ApiConfig.getGenealogyTree}&type=$type';
      if (rootId != null) {
        url += '&root_id=$rootId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? {};
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch tree');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getGenealogyStats)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? {};
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch stats');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

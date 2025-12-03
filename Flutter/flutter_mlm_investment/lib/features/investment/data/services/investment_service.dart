import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';
import '../models/investment_product.dart';
import '../models/user_investment.dart';

class InvestmentService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<InvestmentProduct>> getProducts({
    String? type,
    String? risk,
    String? frequency,
  }) async {
    try {
      String url = ApiConfig.getUrl(ApiConfig.getInvestmentProducts);
      List<String> queryParams = [];
      if (type != null) queryParams.add('type=$type');
      if (risk != null) queryParams.add('risk=$risk');
      if (frequency != null) queryParams.add('frequency=$frequency');

      if (queryParams.isNotEmpty) {
        url += '&${queryParams.join('&')}';
      }

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final headers = await _getHeaders();

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
                'Request timeout. Check your network connection.'),
          );

      final data = jsonDecode(response.body);

      if (response.statusCode == 401) {
        throw Exception('Your session has expired. Please login again.');
      } else if (response.statusCode == 200) {
        if (data['data'] == null || (data['data'] as List).isEmpty) {
          throw Exception('No investment products available at this time.');
        }
        return (data['data'] as List)
            .map((item) => InvestmentProduct.fromJson(item))
            .toList();
      } else {
        throw Exception(data['message'] ??
            'Failed to fetch products (Error ${response.statusCode})');
      }
    } on SocketException catch (e) {
      throw Exception(
          'Network error: Unable to connect to server. ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> invest(int productId, double amount,
      {bool autoRenew = false}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.investNow)),
        headers: await _getHeaders(),
        body: jsonEncode({
          'product_id': productId,
          'amount': amount,
          'auto_renew': autoRenew,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Investment failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> sellInvestment(int investmentId) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/routes/investment_actions.php?action=sell'),
        headers: await _getHeaders(),
        body: jsonEncode({'investment_id': investmentId}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to sell investment');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> toggleAutoRenew(int investmentId, bool autoRenew) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/routes/investment_actions.php?action=toggle_auto_renew'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'investment_id': investmentId,
          'auto_renew': autoRenew,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to update auto-renew');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<UserInvestment>> getMyInvestments({String status = 'all'}) async {
    try {
      String url = ApiConfig.getUrl(ApiConfig.getMyInvestments);
      if (status != 'all') {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return (data['data'] as List)
            .map((item) => UserInvestment.fromJson(item))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch investments');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

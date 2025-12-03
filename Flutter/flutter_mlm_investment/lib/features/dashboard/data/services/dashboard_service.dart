import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';

class DashboardService {
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

  // Get Dashboard Data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final token = await _getToken();
      print('Dashboard Token: $token');

      final url = ApiConfig.getUrl(ApiConfig.getDashboard);
      print('Dashboard URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      print('Dashboard Response Status: ${response.statusCode}');
      print('Dashboard Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch dashboard data');
      }
    } catch (e) {
      print('Dashboard Error: $e');
      rethrow;
    }
  }

  // Get Wallet Balance
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getWalletBalance)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch wallet balance');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get Transactions
  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getTransactions)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch transactions');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get Portfolio (My Investments)
  Future<List<dynamic>> getPortfolio() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/routes/investment.php?action=get_my_investments'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch portfolio');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get Team Members
  Future<List<dynamic>> getTeamMembers() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getTeam)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch team members');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get Today's P&L
  Future<Map<String, dynamic>> getTodayPnl() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getTodayPnl)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch today\'s P&L');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get P&L History
  Future<Map<String, dynamic>> getPnlHistory({required int days}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.getPnlHistory)}&days=$days'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch P&L history');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

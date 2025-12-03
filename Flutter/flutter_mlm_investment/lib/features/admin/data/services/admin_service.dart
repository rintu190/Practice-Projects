import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/shared_prefs.dart';

class AdminService {
  Future<Map<String, dynamic>> triggerProfitCalculation() async {
    final token = await SharedPrefs.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/routes/admin.php?action=trigger_profit_calculation'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(
          data['message'] ?? 'Failed to trigger profit calculation');
    }
  }

  Future<Map<String, dynamic>> getPendingApprovals() async {
    final token = await SharedPrefs.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/routes/admin.php?action=get_pending_approvals'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch pending approvals');
    }
  }

  Future<Map<String, dynamic>> approveSingleItem({
    required String type, // 'deposit', 'withdrawal', 'transfer'
    required int itemId,
  }) async {
    final token = await SharedPrefs.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/routes/admin.php?action=approve_item'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'item_id': itemId,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to approve item');
    }
  }

  Future<Map<String, dynamic>> rejectSingleItem({
    required String type, // 'deposit', 'withdrawal', 'transfer'
    required int itemId,
    required String reason,
  }) async {
    final token = await SharedPrefs.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/routes/admin.php?action=reject_item'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'item_id': itemId,
        'reason': reason,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to reject item');
    }
  }

  Future<Map<String, dynamic>> approveAllDeposits() async {
    final token = await SharedPrefs.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/routes/admin.php?action=approve_deposits'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to approve deposits');
    }
  }

  Future<Map<String, dynamic>> approveAllWithdrawals() async {
    final token = await SharedPrefs.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/routes/admin.php?action=approve_withdrawals'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to approve withdrawals');
    }
  }

  Future<Map<String, dynamic>> approveAllTransfers() async {
    final token = await SharedPrefs.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/routes/admin.php?action=approve_transfers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to approve transfers');
    }
  }
  Future<List<dynamic>> getCommissionRules() async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/routes/commission.php?action=get_commission_rules'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch rules');
    }
  }

  Future<void> updateCommissionRule(int id, double percentage, double fixedAmount, bool isActive) async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/routes/commission.php?action=update_commission_rule'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
        'percentage': percentage,
        'fixed_amount': fixedAmount,
        'is_active': isActive ? 1 : 0,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update rule');
    }
  }
}

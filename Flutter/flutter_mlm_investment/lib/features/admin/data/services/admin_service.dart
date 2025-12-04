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
      Uri.parse(ApiConfig.getUrl(ApiConfig.triggerProfitCalculation)),
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
      Uri.parse(ApiConfig.getUrl(ApiConfig.getPendingApprovals)),
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
      Uri.parse(ApiConfig.getUrl(ApiConfig.approveItem)),
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
      Uri.parse(ApiConfig.getUrl(ApiConfig.rejectItem)),
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
      Uri.parse(ApiConfig.getUrl(ApiConfig.approveDeposits)),
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
      Uri.parse(ApiConfig.getUrl(ApiConfig.approveWithdrawals)),
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
      Uri.parse(ApiConfig.getUrl(ApiConfig.approveTransfers)),
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
      Uri.parse(ApiConfig.getUrl(ApiConfig.getCommissionRules)),
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
      Uri.parse(ApiConfig.getUrl(ApiConfig.updateCommissionRule)),
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

  Future<List<dynamic>> getUsers({String search = ''}) async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    String url = ApiConfig.getUrl(ApiConfig.getUsers);
    if (search.isNotEmpty) {
      url += '&search=$search';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch users');
    }
  }

  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('${ApiConfig.getUrl(ApiConfig.getUserDetailsAdmin)}&user_id=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch user details');
    }
  }

  Future<void> updateUser(int userId, {String? rank, String? status}) async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse(ApiConfig.getUrl(ApiConfig.updateUser)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        if (rank != null) 'rank': rank,
        if (status != null) 'status': status,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update user');
    }
  }

  Future<void> adjustWallet(int userId, double amount, String type, String walletType, String description) async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse(ApiConfig.getUrl(ApiConfig.adjustWallet)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'amount': amount,
        'type': type,
        'wallet_type': walletType,
        'description': description,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to adjust wallet');
    }
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse(ApiConfig.getUrl(ApiConfig.createProduct)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(productData),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to create product');
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> productData) async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse(ApiConfig.getUrl(ApiConfig.updateProduct)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({...productData, 'id': id}),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update product');
    }
  }

  // Approve or reject item (generic method for web portal)
  Future<void> approveItem(String type, int id, bool approve) async {
    if (approve) {
      await approveSingleItem(type: type, itemId: id);
    } else {
      await rejectSingleItem(type: type, itemId: id, reason: 'Rejected by admin');
    }
  }

  // Upload P&L
  Future<void> uploadPnl(double amount, String date) async {
    final token = await SharedPrefs.getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse(ApiConfig.getUrl(ApiConfig.uploadPnl)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'date': date,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to upload P&L');
    }
  }

  // Update commission rule (overloaded for Map parameter)
  Future<void> updateCommissionRuleMap(int id, Map<String, dynamic> data) async {
    final percentage = data['percentage'] as double? ?? 0.0;
    final fixedAmount = data['fixed_amount'] as double? ?? 0.0;
    final isActive = data['is_active'] == 1 || data['is_active'] == true;
    
    await updateCommissionRule(id, percentage, fixedAmount, isActive);
  }
}


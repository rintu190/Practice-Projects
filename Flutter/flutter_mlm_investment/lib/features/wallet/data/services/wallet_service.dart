import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/shared_prefs.dart';

class WalletService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SharedPrefs.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> initiateDeposit({
    required String walletType, // Keep for compatibility but backend ignores it
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      // Use multipart for potential file upload (proof image)
      final token = await SharedPrefs.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/routes/wallet.php?action=add_funds'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['amount'] = amount.toString();
      // wallet_type is no longer sent - backend always uses e_wallet
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'message': data['message'] ?? 'Deposit request submitted for admin approval',
          'order_id': 'PENDING', // Backend doesn't return order_id yet
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to initiate deposit');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required String walletType, // Keep for compatibility but backend ignores it
    required double amount,
    required int bankAccountId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/routes/wallet.php?action=withdraw'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'amount': amount,
          // wallet_type is no longer sent - backend always uses e_wallet
          // bank_account_id is not used yet in backend
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'message': data['message'] ?? 'Withdrawal request submitted for admin approval',
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to request withdrawal');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getBankAccounts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/routes/bank.php?action=get'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final accountData = data['data']?['data'];
        return accountData != null ? [accountData] : [];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch bank accounts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getDepositHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/routes/deposit.php?action=get_history'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch deposit history');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getWithdrawalHistory() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/routes/withdrawal.php?action=get_history'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data'] ?? [];
      } else {
        throw Exception(
            data['message'] ?? 'Failed to fetch withdrawal history');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> addBankAccount({
    required String accountHolder,
    required String accountNumber,
    required String ifsc,
    required String bankName,
    required String branch,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/routes/bank.php?action=add'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'account_holder': accountHolder,
          'account_number': accountNumber,
          'ifsc_code': ifsc,
          'bank_name': bankName,
          'branch': branch,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return;
      } else {
        throw Exception(data['message'] ?? 'Failed to add bank account');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> transferFunds({
    required double amount,
    required String transferType,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/routes/wallet.php?action=transfer';
      final headers = await _getHeaders();
      final body = jsonEncode({
        'amount': amount,
        'transfer_type': transferType,
      });

      print('=== TRANSFER REQUEST ===');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('=== TRANSFER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Transfer processed',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Transfer failed',
          'data': null,
        };
      }
    } catch (e) {
      print('=== TRANSFER ERROR ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }
}

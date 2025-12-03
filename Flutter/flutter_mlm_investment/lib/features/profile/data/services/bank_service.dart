import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';

class BankService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> addBankDetails({
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
    String? branchName,
    String accountType = 'savings',
    String? upiId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.addBank)),
        headers: await _getHeaders(),
        body: jsonEncode({
          'account_holder_name': accountHolderName,
          'account_number': accountNumber,
          'ifsc_code': ifscCode,
          'bank_name': bankName,
          'branch_name': branchName,
          'account_type': accountType,
          'upi_id': upiId,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to add bank details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getBankDetails() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getBank)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch bank details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateBankDetails({
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? branchName,
    String? accountType,
    String? upiId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (accountHolderName != null) body['account_holder_name'] = accountHolderName;
      if (accountNumber != null) body['account_number'] = accountNumber;
      if (ifscCode != null) body['ifsc_code'] = ifscCode;
      if (bankName != null) body['bank_name'] = bankName;
      if (branchName != null) body['branch_name'] = branchName;
      if (accountType != null) body['account_type'] = accountType;
      if (upiId != null) body['upi_id'] = upiId;

      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.updateBank)),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update bank details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';

class KycService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> uploadKyc({
    required String panNumber,
    required String aadhaarNumber,
    File? panImage,
    File? aadhaarFront,
    File? aadhaarBack,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.uploadKyc));
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      
      // Add form fields
      request.fields['pan_number'] = panNumber;
      request.fields['aadhaar_number'] = aadhaarNumber;
      
      // Add files
      if (panImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'pan_image',
          panImage.path,
        ));
      }
      
      if (aadhaarFront != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'aadhaar_front',
          aadhaarFront.path,
        ));
      }
      
      if (aadhaarBack != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'aadhaar_back',
          aadhaarBack.path,
        ));
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getKycStatus() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.getKycStatus)),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch KYC status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

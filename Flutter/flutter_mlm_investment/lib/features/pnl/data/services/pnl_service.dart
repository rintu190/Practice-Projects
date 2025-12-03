import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/pnl.dart';

class PnlService {
  Future<List<Pnl>> fetchDailyPnl(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/routes/investment.php?action=get_daily_pnl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> records = data['data'];
          return records.map((json) => Pnl.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch P&L data');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching P&L: $e');
    }
  }

  Future<void> uploadDailyPnl(File csvFile, String token) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/routes/investment.php?action=upload_daily_pnl'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', csvFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading P&L: $e');
    }
  }
}

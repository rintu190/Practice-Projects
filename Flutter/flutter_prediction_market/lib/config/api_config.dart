import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static Future<http.Response> get(String path) async {
    final urlsToTry = [
      '$baseUrl$path',
      if (baseUrl != 'http://localhost:8000') 'http://localhost:8000$path',
      'http://127.0.0.1:8000$path',
    ];

    for (final url in urlsToTry) {
      try {
        final res = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          return res;
        }
      } catch (e) {
        debugPrint('Failed connecting to $url: $e');
      }
    }

    throw Exception('Could not reach backend API server at $baseUrl');
  }

  static Future<http.Response> post(String path, {Map<String, dynamic>? body, String? jsonBody}) async {
    final urlsToTry = [
      '$baseUrl$path',
      if (baseUrl != 'http://localhost:8000') 'http://localhost:8000$path',
      'http://127.0.0.1:8000$path',
    ];

    for (final url in urlsToTry) {
      try {
        final res = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonBody,
            )
            .timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          return res;
        }
      } catch (e) {
        debugPrint('Failed posting to $url: $e');
      }
    }

    throw Exception('Could not reach backend API server at $baseUrl');
  }
}

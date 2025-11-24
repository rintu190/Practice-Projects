import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/api_constants.dart';
import '../exceptions/api_exception.dart';
import 'storage_service.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final Connectivity _connectivity = Connectivity();

  // GET request
  Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    await _checkConnectivity();
    
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth);

    try {
      final response = await _client
          .get(url, headers: headers)
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('DEBUG: SocketException: $e');
      throw NetworkException();
    } on http.ClientException catch (e) {
      print('DEBUG: ClientException: $e');
      throw NetworkException();
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    await _checkConnectivity();

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth);

    try {
      final response = await _client
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('DEBUG: SocketException: $e');
      throw NetworkException();
    } on http.ClientException catch (e) {
      print('DEBUG: ClientException: $e');
      throw NetworkException();
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    await _checkConnectivity();

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth);

    try {
      final response = await _client
          .delete(url, headers: headers)
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('DEBUG: SocketException: $e');
      throw NetworkException();
    } on http.ClientException catch (e) {
      print('DEBUG: ClientException: $e');
      throw NetworkException();
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    await _checkConnectivity();

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth);

    try {
      final response = await _client
          .put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('DEBUG: SocketException: $e');
      throw NetworkException();
    } on http.ClientException catch (e) {
      print('DEBUG: ClientException: $e');
      throw NetworkException();
    }
  }

  // Upload file
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'image',
    bool requiresAuth = true,
  }) async {
    await _checkConnectivity();

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', url);

    // Add headers
    final headers = await _getHeaders(requiresAuth);
    request.headers.addAll(headers);

    // Add file
    request.files.add(await http.MultipartFile.fromPath(
      fieldName,
      file.path,
    ));

    try {
      final streamedResponse = await request.send().timeout(ApiConstants.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('DEBUG: SocketException: $e');
      throw NetworkException();
    } on http.ClientException catch (e) {
      print('DEBUG: ClientException: $e');
      throw NetworkException();
    }
  }

  // Get headers with optional auth token
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    if (requiresAuth) {
      final token = await StorageService.getToken();
      print('DEBUG: Retrieving token for request. Token found: ${token != null}');
      if (token == null) {
        print('DEBUG: No token found in storage!');
        throw UnauthorizedException(message: 'No authentication token found');
      }
      return ApiConstants.authHeaders(token);
    }
    return ApiConstants.headers;
  }

  // Check network connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw NetworkException();
    }
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Try to parse response body
    dynamic data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (e) {
      data = response.body;
    }

    switch (statusCode) {
      case 200:
      case 201:
        return data;
      case 400:
        throw ValidationException(
          message: data is Map ? (data['error'] ?? 'Validation failed') : 'Bad request',
          data: data,
        );
      case 401:
        throw UnauthorizedException(
          message: data is Map ? (data['error'] ?? 'Unauthorized') : 'Unauthorized',
        );
      case 404:
        throw NotFoundException(
          message: data is Map ? (data['error'] ?? 'Not found') : 'Resource not found',
        );
      case 500:
      case 502:
      case 503:
        throw ServerException(
          message: data is Map ? (data['error'] ?? 'Server error') : 'Server error',
        );
      default:
        throw ApiException(
          message: data is Map ? (data['error'] ?? 'Unknown error') : 'Unknown error occurred',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  void dispose() {
    _client.close();
  }
}

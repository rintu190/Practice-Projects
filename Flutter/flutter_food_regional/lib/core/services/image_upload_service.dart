import 'dart:io';
import 'package:flutter_food_regional/core/services/api_client.dart';

class ImageUploadService {
  final ApiClient _apiClient = ApiClient();

  Future<String> uploadImage(File imageFile) async {
    try {
      final response = await _apiClient.uploadFile(
        '/upload',
        imageFile,
        fieldName: 'image',
        requiresAuth: false,
      );
      
      return response['url'];
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}

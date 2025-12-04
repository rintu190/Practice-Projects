import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/shared_prefs.dart';

class SupportService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SharedPrefs.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==================== TICKETS ====================
  
  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String description,
    String category = 'general',
    String priority = 'medium',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=create_ticket'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'subject': subject,
        'description': description,
        'category': category,
        'priority': priority,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create ticket');
    }
  }

  Future<List<dynamic>> getMyTickets({String status = 'all'}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=get_my_tickets&status=$status'),
      headers: await _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch tickets');
    }
  }

  Future<List<dynamic>> getAllTickets({String status = 'all', String category = 'all'}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=get_all_tickets&status=$status&category=$category'),
      headers: await _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch tickets');
    }
  }

  Future<Map<String, dynamic>> getTicketDetails(int ticketId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=get_ticket_details&ticket_id=$ticketId'),
      headers: await _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch ticket details');
    }
  }

  Future<void> addTicketMessage(int ticketId, String message) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=add_ticket_message'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'ticket_id': ticketId,
        'message': message,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to add message');
    }
  }

  Future<void> updateTicketStatus(int ticketId, String status) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=update_ticket_status'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'ticket_id': ticketId,
        'status': status,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update ticket');
    }
  }

  // ==================== FAQs ====================
  
  Future<List<dynamic>> getFAQs({String category = 'all'}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=get_faqs&category=$category'),
      headers: await _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch FAQs');
    }
  }

  Future<void> manageFAQ({
    required String action,
    int? id,
    String? category,
    String? question,
    String? answer,
    int? displayOrder,
    bool? isActive,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=manage_faq'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'action': action,
        if (id != null) 'id': id,
        if (category != null) 'category': category,
        if (question != null) 'question': question,
        if (answer != null) 'answer': answer,
        if (displayOrder != null) 'display_order': displayOrder,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to manage FAQ');
    }
  }

  // ==================== CHAT ====================
  
  Future<void> sendChatMessage(String message) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/routes/support.php?action=send_chat_message'),
      headers: await _getHeaders(),
      body: jsonEncode({'message': message}),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to send message');
    }
  }

  Future<List<dynamic>> getChatMessages({int? userId, int limit = 50}) async {
    String url = '${ApiConfig.baseUrl}/routes/support.php?action=get_chat_messages&limit=$limit';
    if (userId != null) {
      url += '&user_id=$userId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch messages');
    }
  }
}

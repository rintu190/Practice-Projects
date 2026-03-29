import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/saree_model.dart';
import '../models/seller_model.dart';
import '../models/artisan_model.dart';
import '../models/order_model.dart';

class ApiRepository {
  static Future<List<Saree>> getSarees({String? category, String? type, String? sellerId}) async {
    try {
      String queryParams = '';
      if (category != null && category != 'All') queryParams += 'category=$category&';
      if (type != null && type != 'All') queryParams += 'type=$type&';
      if (sellerId != null) queryParams += 'seller_id=$sellerId';

      final uri = Uri.parse('${ApiConfig.sareesList}?$queryParams');
      final response = await http.get(uri, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Saree.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sarees from API');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Saree> getSareeDetails(String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.sareeDetails}?id=$id'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return Saree.fromJson(json.decode(response.body));
    } else {
      throw Exception('Saree not found');
    }
  }

  static Future<List<Seller>> getSellers() async {
    final response = await http.get(Uri.parse(ApiConfig.sellersList), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Seller.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sellers');
    }
  }

  static Future<Seller> getSellerProfile(String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.sellerProfile}?id=$id'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return Seller.fromJson(json.decode(response.body));
    } else {
      throw Exception('Seller not found');
    }
  }

  static Future<List<Artisan>> getArtisans() async {
    final response = await http.get(Uri.parse(ApiConfig.artisansList), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Artisan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load artisans');
    }
  }

  static Future<List<Order>> getOrdersBySeller(String sellerId) async {
    final response = await http.get(Uri.parse('${ApiConfig.ordersListBySeller}?seller_id=$sellerId'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final response = await http.put(
      Uri.parse(ApiConfig.orderUpdateStatus),
      headers: ApiConfig.headers,
      body: json.encode({
        'id': orderId,
        'status': status.name,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }

  static Future<String> createOrder(Order order) async {
    final response = await http.post(
      Uri.parse(ApiConfig.ordersCreate),
      headers: ApiConfig.headers,
      body: json.encode({
        'customerId': 'guest',
        'customerName': order.customerName,
        'customerEmail': order.customerEmail,
        'customerAddress': order.customerAddress,
        'totalAmount': order.totalAmount,
        'sellerId': order.sellerId,
        'items': order.items.map((i) => i.toJson()).toList(),
      }),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body)['orderId'];
    } else {
      throw Exception('Failed to create order');
    }
  }
}


import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../../domain/models/order.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  Future<List<Order>> getOrders() async {
    print('DEBUG: Fetching orders...');
    try {
      final response = await _apiClient.get(
        ApiConstants.orders,
        requiresAuth: true,
      );
      
      if (response == null || response is! List) {
        return [];
      }

      final List<dynamic> data = response;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('DEBUG: Error fetching orders: $e');
      rethrow;
    }
  }

  Future<Order> getOrder(String id) async {
    final response = await _apiClient.get(
      '${ApiConstants.orders}/$id',
      requiresAuth: true,
    );
    return Order.fromJson(response as Map<String, dynamic>);
  }

  Future<Order> createOrder({
    required String restaurantId,
    required String addressId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    print('DEBUG: Creating order...');
    final body = {
      'restaurantId': restaurantId,
      'addressId': addressId,
      'totalAmount': totalAmount,
      'items': items,
    };
    print('DEBUG: Order payload: $body');

    try {
      final response = await _apiClient.post(
        ApiConstants.orders,
        body: body,
        requiresAuth: true,
      );
      print('DEBUG: Create order response: $response');
      return Order.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('DEBUG: Error creating order: $e');
      rethrow;
    }
  }
}


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

  Future<void> updateOrderStatus(String orderId, String status) async {
    print('DEBUG: Updating order status: $orderId -> $status');
    try {
      await _apiClient.put(
        '${ApiConstants.orders}/$orderId/status',
        body: {'status': status},
        requiresAuth: true,
      );
    } catch (e) {
      print('DEBUG: Error updating order status: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRiders() async {
    print('DEBUG: Fetching riders...');
    try {
      // ApiClient expects a relative path, not a full URL
      final response = await _apiClient.get(
        '/users/riders',
        requiresAuth: true,
      );
      
      print('DEBUG: Response type: ${response.runtimeType}');
      print('DEBUG: Response: $response');
      
      if (response == null || response is! List) {
        print('DEBUG: Response is not a list');
        return [];
      }

      print('DEBUG: Found ${response.length} riders');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('DEBUG: Error fetching riders: $e');
      rethrow;
    }
  }

  Future<void> assignRider(String orderId, String riderId) async {
    print('DEBUG: Assigning rider $riderId to order $orderId');
    try {
      await _apiClient.put(
        '${ApiConstants.orders}/$orderId/assign-rider',
        body: {'riderId': riderId},
        requiresAuth: true,
      );
    } catch (e) {
      print('DEBUG: Error assigning rider: $e');
      rethrow;
    }
  }
}

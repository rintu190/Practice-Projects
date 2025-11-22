import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../../domain/models/order.dart';
import '../services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ApiClient());
});

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<Order>>(() {
  return OrderNotifier();
});

class OrderNotifier extends AsyncNotifier<List<Order>> {
  OrderService get _orderService => ref.read(orderServiceProvider);

  @override
  Future<List<Order>> build() async {
    return _orderService.getOrders();
  }

  Future<void> createOrder({
    required String restaurantId,
    required String addressId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _orderService.createOrder(
        restaurantId: restaurantId,
        addressId: addressId,
        totalAmount: totalAmount,
        items: items,
      );
      return _orderService.getOrders();
    });
  }
}

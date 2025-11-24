import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/order.dart';
import '../../data/providers/order_provider.dart';

class OrderStatusScreen extends ConsumerWidget {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(orderProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }
          // Find the latest pending order (status not delivered)
          final pendingOrders = orders
              .where((o) => o.status != 'delivered')
              .toList()
            ..sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0);
          if (pendingOrders.isEmpty) {
            return const Center(child: Text('All orders are delivered'));
          }
          final order = pendingOrders.first;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id?.substring(0, 8) ?? ''}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  order.restaurantName ?? 'Unknown Restaurant',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${order.items?.length ?? 0} items • ₹${order.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text('Order Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildProgressStepper(order.status),
                const SizedBox(height: 24),
                Text(
                  'Placed on ${order.createdAt != null ? DateFormat('MMM d, yyyy').format(order.createdAt!) : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProgressStepper(String status) {
    const stages = ['pending', 'preparing', 'rider_assigned', 'delivered'];
    const labels = {
      'pending': 'Order Received',
      'preparing': 'Prep Started',
      'rider_assigned': 'Rider Assigned',
      'delivered': 'Delivered',
    };
    final currentIndex = stages.indexOf(status);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (i) {
        final isActive = i <= currentIndex && currentIndex != -1;
        return Column(
          children: [
            Icon(
              Icons.circle,
              size: 16,
              color: isActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              labels[stages[i]] ?? stages[i],
              style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.grey),
            ),
          ],
        );
      }),
    );
  }
}

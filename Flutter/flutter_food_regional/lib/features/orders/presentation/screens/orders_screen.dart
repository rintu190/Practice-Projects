import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/order.dart';
import '../../data/providers/order_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No orders yet'),
                ],
              ),
            );
          }

          // Find the latest order that is not completed (status not 'delivered')
          final pendingOrders = orders.where((o) => o.status != 'delivered').toList()
            ..sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0);
          final hasPending = pendingOrders.isNotEmpty;

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = orders[index];
              final isLatestPending = hasPending && order.id == pendingOrders.first.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id?.substring(0, 8) ?? ''}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            order.status.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: order.status == 'delivered' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.restaurantName ?? 'Unknown Restaurant',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.items?.length ?? 0} items • ₹${order.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      const Divider(height: 24),
                      // Show progress stepper only for the latest pending order
                      if (isLatestPending) ...[
                        const Text('Order Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildProgressStepper(order.status),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.createdAt != null
                                ? DateFormat('MMM d, yyyy').format(order.createdAt!)
                                : '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              // Reorder logic placeholder
                            },
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Reorder'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(orderProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simple horizontal stepper showing order stages
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
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }
}

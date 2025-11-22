import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/order.dart';
import '../../data/providers/order_provider.dart';
import 'package:go_router/go_router.dart';

class OrderProgressBar extends ConsumerWidget {
  const OrderProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);
    return ordersAsync.when(
      data: (orders) {
        final pendingOrders = orders.where((o) => o.status != 'delivered').toList()
          ..sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0);
        if (pendingOrders.isEmpty) return const SizedBox.shrink();
        final order = pendingOrders.first;
        return GestureDetector(
          onTap: () => context.go('/order-status'),
          child: Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.id?.substring(0, 8) ?? ''}', style: Theme.of(context).textTheme.bodySmall),
                _buildProgressStepper(order.status),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildProgressStepper(String status) {
    const stages = ['pending', 'preparing', 'rider_assigned', 'delivered'];
    const labels = {
      'pending': 'Received',
      'preparing': 'Prep',
      'rider_assigned': 'Rider',
      'delivered': 'Done',
    };
    final currentIndex = stages.indexOf(status);
    return Row(
      children: List.generate(stages.length, (i) {
        final isActive = i <= currentIndex && currentIndex != -1;
        return Row(
          children: [
            Icon(Icons.circle, size: 10, color: isActive ? Colors.green : Colors.grey),
            const SizedBox(width: 2),
            Text(labels[stages[i]] ?? stages[i], style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.grey)),
            if (i < stages.length - 1) const SizedBox(width: 4),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/order.dart';
import '../../data/providers/order_provider.dart';

class OrderStatusScreen extends ConsumerWidget {
  final String? orderId;

  const OrderStatusScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/orders');
            }
          },
        ),
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

          Order? order;
          if (orderId != null) {
            try {
              order = orders.firstWhere((o) => o.id == orderId);
            } catch (_) {
              // Order not found in list (maybe not loaded yet or invalid ID)
            }
          }

          // Fallback to latest pending order if no ID provided or not found
          if (order == null) {
            final pendingOrders = orders
                .where((o) => o.status != 'delivered')
                .toList()
              ..sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0);
            
            if (pendingOrders.isNotEmpty) {
              order = pendingOrders.first;
            } else if (orders.isNotEmpty) {
               // If no pending, just show the latest one
               orders.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0);
               order = orders.first;
            }
          }

          if (order == null) {
             return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        order!.status.toUpperCase().replaceAll('_', ' '),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(order.status),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order #${order.id?.substring(0, 8) ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Stepper
                _buildProgressStepper(context, order.status),
                const SizedBox(height: 32),

                // Restaurant Details
                _buildSectionTitle(context, 'Restaurant'),
                Card(
                  margin: const EdgeInsets.only(top: 8, bottom: 24),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: order.restaurantImage != null
                          ? NetworkImage(order.restaurantImage!)
                          : null,
                      child: order.restaurantImage == null
                          ? const Icon(Icons.restaurant)
                          : null,
                    ),
                    title: Text(order.restaurantName ?? 'Unknown Restaurant'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.restaurantAddress != null) Text(order.restaurantAddress!),
                        if (order.restaurantPhone != null) Text(order.restaurantPhone!),
                      ],
                    ),
                  ),
                ),

                // Rider Details
                _buildSectionTitle(context, 'Delivery Partner'),
                Card(
                  margin: const EdgeInsets.only(top: 8, bottom: 24),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.delivery_dining, color: Colors.white),
                    ),
                    title: Text(order.riderName ?? 'Waiting for rider...'),
                    subtitle: order.riderName != null ? const Text('On the way') : const Text('Assigning soon'),
                    trailing: order.riderName != null && order!.riderPhone != null
                        ? IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () async {
                              try {
                                final phoneNumber = order!.riderPhone!.replaceAll(RegExp(r'[^\d+]'), '');
                                final Uri launchUri = Uri(
                                  scheme: 'tel',
                                  path: phoneNumber,
                                );
                                await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error calling rider: $e')),
                                  );
                                }
                              }
                            },
                          )
                        : null,
                  ),
                ),

                // Order Items
                _buildSectionTitle(context, 'Order Items'),
                Card(
                  margin: const EdgeInsets.only(top: 8, bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (order.items != null)
                          ...order.items!.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey[300]!),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${item.quantity}x',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              item.name ?? 'Item',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF6C63FF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'handover':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  Widget _buildProgressStepper(BuildContext context, String status) {
    const stages = ['pending', 'rider_assigned', 'preparing', 'handover', 'delivered'];
    const labels = {
      'pending': 'Ordered',
      'rider_assigned': 'Rider Assigned',
      'preparing': 'Preparation',
      'handover': 'On Way',
      'delivered': 'Delivered',
    };
    
    int currentIndex = stages.indexOf(status);
    // Handle unknown status or cancelled
    if (currentIndex == -1) currentIndex = 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < stages.length; i++) ...[
          // Step Item
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= currentIndex ? const Color(0xFF6C63FF) : Colors.grey[300],
                ),
                child: Icon(
                  i <= currentIndex ? Icons.check : Icons.circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[stages[i]] ?? '',
                style: TextStyle(
                  fontSize: 10,
                  color: i <= currentIndex ? Colors.black : Colors.grey,
                  fontWeight: i <= currentIndex ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          // Connecting Line (if not last)
          if (i < stages.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: i < currentIndex ? const Color(0xFF6C63FF) : Colors.grey[300],
                margin: const EdgeInsets.only(top: 14, left: 4, right: 4),
              ),
            ),
        ],
      ],
    );
  }
}

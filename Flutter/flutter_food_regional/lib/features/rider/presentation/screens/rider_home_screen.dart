import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../orders/data/providers/order_provider.dart';
import '../../../orders/domain/models/order.dart';
import '../../../../core/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/data/providers/auth_provider.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  List<Map<String, dynamic>> _commissions = [];
  double _totalEarnings = 0.0;
  bool _commissionsLoaded = false;
  int _selectedIndex = 0;

  // Modern color palette
  static const Color primaryBlue = Color(0xFF5BA3D0);
  static const Color backgroundColor = Color(0xFFF5F9FC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentOrange = Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    _loadCommissions();
  }

  Future<void> _loadCommissions() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/commissions', requiresAuth: true);
      setState(() {
        _commissions = List<Map<String, dynamic>>.from(response['commissions'] ?? []);
        _totalEarnings = double.tryParse(response['total']?.toString() ?? '0') ?? 0.0;
        _commissionsLoaded = true;
      });
    } catch (e) {
      print('Error loading commissions: $e');
      setState(() {
        _commissionsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildHeader(user?.name ?? 'Rider'),
            
            // Tab Selector
            _buildTabSelector(),
            
            // Content
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  final activeOrders = orders.where((o) => 
                    o.status != 'delivered' && o.status != 'cancelled'
                  ).toList();
                  final historyOrders = orders.where((o) => 
                    o.status == 'delivered' || o.status == 'cancelled'
                  ).toList();

                  if (_selectedIndex == 0) {
                    return _buildOrderList(activeOrders, ref, true);
                  } else if (_selectedIndex == 1) {
                    return _buildOrderList(historyOrders, ref, false);
                  } else {
                    return _buildEarningsTab();
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator(color: primaryBlue)),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String riderName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $riderName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ready for deliveries',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: primaryBlue),
                    onPressed: () {
                      ref.refresh(orderProvider);
                      _loadCommissions();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: primaryBlue),
                    onPressed: () async {
                      await AuthService().logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton('Active', Icons.delivery_dining, 0),
          _buildTabButton('History', Icons.history, 1),
          _buildTabButton('Earnings', Icons.account_balance_wallet, 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, WidgetRef ref, bool isActive) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.delivery_dining : Icons.history,
              size: 64,
              color: textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active orders' : 'No order history',
              style: const TextStyle(color: textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildModernOrderCard(order, ref, isActive);
      },
    );
  }

  Widget _buildModernOrderCard(Order order, WidgetRef ref, bool isActive) {
    final canMarkDelivered = isActive && order.status != 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ORDER #${order.id?.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Route Display (Restaurant → Customer)
            _buildRouteDisplay(order),
            
            const SizedBox(height: 16),
            
            // Price and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: accentOrange,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Order Time',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm a').format(order.createdAt ?? DateTime.now()),
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(order.createdAt ?? DateTime.now()),
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (canMarkDelivered) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(orderProvider.notifier).updateStatus(order.id!, 'delivered');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Mark as Delivered',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRouteDisplay(Order order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Restaurant (From)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pickup From',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.restaurantName ?? 'Unknown',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.restaurantAddress != null)
                      Text(
                        order.restaurantAddress!,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (order.restaurantLatitude != null && order.restaurantLongitude != null)
                IconButton(
                  icon: const Icon(Icons.map, color: primaryBlue, size: 20),
                  onPressed: () => _openMap(order.restaurantLatitude!, order.restaurantLongitude!),
                ),
            ],
          ),
          
          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Container(
                  width: 2,
                  height: 20,
                  color: primaryBlue.withOpacity(0.3),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_downward, color: primaryBlue, size: 16),
              ],
            ),
          ),
          
          // Customer (To)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deliver To',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.userName ?? 'Unknown',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.houseNumber != null)
                      Text(
                        '${order.houseNumber}, ${order.locality ?? ""}',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (order.latitude != null && order.longitude != null)
                IconButton(
                  icon: const Icon(Icons.map, color: primaryBlue, size: 20),
                  onPressed: () => _openMap(order.latitude!, order.longitude!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    if (!_commissionsLoaded) {
      return const Center(child: CircularProgressIndicator(color: primaryBlue));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Earnings Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryBlue, Color(0xFF4A90C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Total Earnings',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '₹ ${_totalEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Commission List Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Commission History',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Commission List
        if (_commissions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No commissions yet',
                style: TextStyle(color: textSecondary, fontSize: 16),
              ),
            ),
          )
        else
          ..._commissions.map((commission) {
            final isPending = commission['status'] == 'pending';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${commission['percentage']}%',
                      style: TextStyle(
                        color: isPending ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${commission['order_id'].toString().substring(0, 8)}',
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPending ? Colors.orange : Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPending ? 'PENDING' : 'APPROVED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(
                            DateTime.parse(commission['created_at']),
                          ),
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹${double.parse(commission['amount'].toString()).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isPending ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return primaryBlue;
      case 'rider_assigned':
        return const Color(0xFF9B59B6);
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _openMap(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map')),
        );
      }
    }
  }
}

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background header with cloud divider
          _buildHeader(user?.name ?? "Rider"),
          
          // Content with IndexedStack
          SafeArea(
            child: ordersAsync.when(
              data: (orders) {
                final activeOrders = orders.where((o) => 
                  o.status != 'delivered' && o.status != 'cancelled'
                ).toList();
                final historyOrders = orders.where((o) => 
                  o.status == 'delivered' || o.status == 'cancelled'
                ).toList();

                return IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildOrderList(activeOrders, ref, true),
                    _buildOrderList(historyOrders, ref, false),
                    _buildEarningsTab(),
                  ],
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          
          // Top AppBar with interactive elements
          _buildAppBar(user?.name ?? "Rider"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Active Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String riderName) {
    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          // Blue background with cloud shape
          Positioned.fill(
            child: CustomPaint(
              painter: _CloudHeaderPainter(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          // Illustration area
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40), // Space for AppBar
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delivery_dining,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Rider Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String riderName) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hi, $riderName',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    ref.refresh(orderProvider);
                    _loadCommissions();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    context.push('/edit-profile');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
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
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
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
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              isActive ? 'No active orders' : 'No order history',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 320, left: 16, right: 16, bottom: 20),
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
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ORDER #${order.id?.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Route Display (Restaurant → Customer)
            _buildRouteDisplay(order),
            
            SizedBox(height: 16),
            
            // Price and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹ ${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Order Time',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm a').format(order.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(order.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (canMarkDelivered) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(orderProvider.notifier).updateStatus(order.id!, 'delivered');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Restaurant (From)
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant, color: Colors.green, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup From',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      order.restaurantName ?? 'Unknown',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.restaurantAddress != null)
                      Text(
                        order.restaurantAddress!,
                        style: TextStyle(
                          color: Colors.grey,
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
                  icon: Icon(Icons.map, color: Theme.of(context).colorScheme.primary, size: 20),
                  onPressed: () => _openMap(order.restaurantLatitude!, order.restaurantLongitude!),
                ),
            ],
          ),
          
          // Arrow
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 20),
                Container(
                  width: 2,
                  height: 20,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.primary, size: 16),
              ],
            ),
          ),
          
          // Customer (To)
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deliver To',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      order.userName ?? 'Unknown',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.houseNumber != null)
                      Text(
                        '${order.houseNumber}, ${order.locality ?? ""}',
                        style: TextStyle(
                          color: Colors.grey,
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
                  icon: Icon(Icons.map, color: Theme.of(context).colorScheme.primary, size: 20),
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
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    return ListView(
      padding: EdgeInsets.only(top: 340, left: 20, right: 20, bottom: 20),
      children: [
        // Total Earnings Card
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Color(0xFF4A90C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Total Earnings',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '₹ ${_totalEarnings.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Commission List Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Commission History',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        SizedBox(height: 12),
        
        // Commission List
        if (_commissions.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No commissions yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          ..._commissions.map((commission) {
            final status = commission['status'];
            final isRejected = status == 'rejected';
            final isPending = status == 'pending';
            final isApproved = status == 'approved';
            
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isRejected 
                          ? Colors.red.withOpacity(0.1) 
                          : (isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${commission['percentage']}%',
                      style: TextStyle(
                        color: isRejected ? Colors.red : (isPending ? Colors.orange : Colors.green),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${commission['order_id'].toString().substring(0, 8)}',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isRejected ? Colors.red : (isPending ? Colors.orange : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isRejected ? 'REJECTED' : (isPending ? 'PENDING' : 'APPROVED'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(
                            DateTime.parse(commission['created_at']),
                          ),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '₹${double.parse(commission['amount'].toString()).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isRejected ? Colors.red : (isPending ? Colors.orange : Colors.green),
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
        return Theme.of(context).colorScheme.primary;
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

// Cloud Header Painter for the divider
class _CloudHeaderPainter extends CustomPainter {
  final Color color;

  _CloudHeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Start from top left
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.9); // Right side lower

    // S-curve from right to left
    path.cubicTo(
      size.width * 0.75, size.height * 1.0, // Dip down
      size.width * 0.25, size.height * 0.8, // Arch up (lowered from 0.6)
      0, size.height * 0.85, // Left side higher
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

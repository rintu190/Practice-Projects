import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/data/api_repository.dart';
import '../../core/models/order_model.dart';
import '../../core/models/seller_model.dart';
import '../../core/models/saree_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/auth_service.dart';
import 'manage_sarees_screen.dart';
import 'manage_orders_screen.dart';
import 'edit_shop_profile_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    final sellerId = context.read<AuthService>().sellerId;
    if (sellerId == null) {
      // Handle the case where seller is not loaded yet or doesn't exist
      setState(() {
        _dashboardFuture = Future.error('Seller profile not found. Please logout and login again.');
      });
      return;
    }
    _dashboardFuture = _fetchDashboard(sellerId);
  }

  Future<_DashboardData> _fetchDashboard(String sellerId) async {
    final results = await Future.wait([
      ApiRepository.getSellerProfile(sellerId),
      ApiRepository.getSarees(sellerId: sellerId),
      ApiRepository.getOrdersBySeller(sellerId),
    ]);
    return _DashboardData(
      seller: results[0] as Seller,
      sarees: results[1] as List<Saree>,
      orders: results[2] as List<Order>,
    );
  }

  String _formatEarnings(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_DashboardData>(
        future: _dashboardFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('Could not load dashboard', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(_loadDashboard),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          }

          final data = snap.data!;
          final seller = data.seller;
          final recentOrders = data.orders.take(3).toList();

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: seller.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(Icons.person),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seller Dashboard',
                                style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              Text(
                                seller.storeName,
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.inventory_2_outlined,
                              label: 'Listings',
                              value: '${data.sarees.length}',
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.shopping_bag_outlined,
                              label: 'Orders',
                              value: '${seller.totalOrders}',
                              color: const Color(0xFF2ECC71),
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.pending_actions_outlined,
                              label: 'Pending',
                              value: '${seller.pendingOrders}',
                              color: AppColors.orangeAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Earning',
                              value: '₹${_formatEarnings(seller.totalEarning)}',
                              color: const Color(0xFF3498DB),
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.star_outline,
                              label: 'Rating',
                              value: '${seller.rating}',
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.visibility_outlined,
                              label: 'Views',
                              value: '1.2K',
                              color: const Color(0xFF9B59B6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Management title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text(
                      'Management',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ),

                // Management cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisExtent: 80,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildListDelegate([
                      _ManagementCard(
                        title: 'Manage Sarees',
                        subtitle: 'Add, edit or remove saree listings',
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageSareesScreen()),
                        ).then((_) => setState(_loadDashboard)),
                      ),
                      _ManagementCard(
                        title: 'Manage Orders',
                        subtitle: 'Track and update customer orders',
                        icon: Icons.shopping_basket_rounded,
                        color: const Color(0xFF2ECC71),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageOrdersScreen()),
                        ),
                      ),
                      _ManagementCard(
                        title: 'Manage Profile Details',
                        subtitle: 'Update shop bio, location and contact',
                        icon: Icons.store_rounded,
                        color: AppColors.orangeAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditShopProfileScreen()),
                        ),
                      ),
                    ]),
                  ),
                ),

                // Recent Orders
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Orders',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ManageOrdersScreen()),
                          ),
                          child: Text(
                            'View All',
                            style: GoogleFonts.poppins(
                                color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                recentOrders.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('No recent orders')),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final order = recentOrders[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.receipt_long,
                                          color: AppColors.primary, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(order.customerName,
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600, fontSize: 14)),
                                          Text('Order #${order.id}',
                                              style: GoogleFonts.poppins(
                                                  color: AppColors.textSecondary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${order.totalAmount.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary),
                                        ),
                                        Text(
                                          order.statusDisplay,
                                          style: GoogleFonts.poppins(
                                              color: _getStatusColor(order.status),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            childCount: recentOrders.length,
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageSareesScreen(showAddForm: true)),
        ).then((_) => setState(_loadDashboard)),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Upload Saree',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return AppColors.orangeAccent;
      case OrderStatus.processing: return const Color(0xFF3498DB);
      case OrderStatus.shipped: return AppColors.primary;
      case OrderStatus.delivered: return const Color(0xFF2ECC71);
      case OrderStatus.cancelled: return Colors.red;
    }
  }
}

class _DashboardData {
  final Seller seller;
  final List<Saree> sarees;
  final List<Order> orders;
  _DashboardData({required this.seller, required this.sarees, required this.orders});
}

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

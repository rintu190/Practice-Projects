import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/data/api_repository.dart';
import '../../core/models/order_model.dart';
import '../../core/widgets/saree_image.dart';
import '../auth/auth_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _searchQuery = '';
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final userId = context.read<AuthService>().userId;
    if (userId != null) {
      _ordersFuture = ApiRepository.getOrdersByCustomer(userId);
    } else {
      // Not logged in — return empty list gracefully
      _ordersFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: _ordersFuture,
      builder: (context, snap) {
        final allOrders = snap.data ?? [];
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: true,
                  expandedHeight: 180,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: AppColors.textPrimary),
                  title: Text(
                    'My Orders',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 20),
                      child: _buildSearchBar(),
                    ),
                  ),
                  bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle:
                        GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                    unselectedLabelStyle:
                        GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Processing'),
                      Tab(text: 'Shipped'),
                      Tab(text: 'Delivered'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
              ],
              body: snap.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : snap.hasError
                      ? _buildErrorState()
                      : TabBarView(
                          children: [
                            _buildOrderList('All', allOrders),
                            _buildOrderList('processing', allOrders),
                            _buildOrderList('shipped', allOrders),
                            _buildOrderList('delivered', allOrders),
                            _buildOrderList('cancelled', allOrders),
                          ],
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by Order ID...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildOrderList(String statusFilter, List<Order> allOrders) {
    final filtered = allOrders.where((order) {
      final matchesStatus =
          statusFilter == 'All' || order.status.name == statusFilter;
      final matchesSearch =
          order.id.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(statusFilter);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return _OrderCard(order: filtered[index]);
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text('Could not load orders.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => setState(_loadOrders),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? 'No $status Orders' : 'No results for "$_searchQuery"',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchQuery.isEmpty
                  ? 'You haven\'t placed any orders in this category yet.'
                  : 'Check the Order ID and try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 32),
          if (_searchQuery.isEmpty && status == 'All')
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Start Shopping', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.orangeAccent;
      case OrderStatus.processing:
        return const Color(0xFF3498DB);
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.delivered:
        return const Color(0xFF2ECC71);
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Order Header
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.primary.withValues(alpha: 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER #${order.id}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Placed on ${_formatDate(order.orderDate)}',
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),

            // Order Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildItemPreview(order.items),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Grand Total',
                            style: GoogleFonts.poppins(
                                color: AppColors.textSecondary, fontSize: 11),
                          ),
                          Text(
                            '₹${order.totalAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            'Reorder',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            'View Details',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            order.statusDisplay,
            style: GoogleFonts.poppins(
                color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPreview(List<OrderItem> items) {
    return Row(
      children: [
        ...items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                  color: AppColors.background,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(
                      item.saree.imageUrls.isNotEmpty ? item.saree.imageUrls.first : ''),
                ),
              ),
            )),
        if (items.length > 2)
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Center(
              child: Text(
                '+${items.length - 2}',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(String url) {
    return SareeImage(
        imageUrl: url, 
        fit: BoxFit.cover,
        errorWidget: const Icon(Icons.checkroom, size: 24, color: AppColors.textSecondary),
    );
  }
}

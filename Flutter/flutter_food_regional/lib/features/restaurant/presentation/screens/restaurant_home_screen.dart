import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../orders/data/providers/order_provider.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/presentation/widgets/image_picker_widget.dart';

class RestaurantHomeScreen extends ConsumerStatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  ConsumerState<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends ConsumerState<RestaurantHomeScreen> {
  // Modern color palette
  static const Color primaryBlue = Color(0xFF5BA3D0);
  static const Color backgroundColor = Color(0xFFF5F9FC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentOrange = Color(0xFFFF6B6B);
  
  List<Map<String, dynamic>> _commissions = [];
  double _totalEarnings = 0.0;
  bool _commissionsLoaded = false;
  Map<String, dynamic>? _restaurantData;
  bool _restaurantLoaded = false;
  List<Map<String, dynamic>> _menuItems = [];
  bool _menuItemsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCommissions();
    _loadRestaurantData();
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

  Future<void> _loadRestaurantData() async {
    try {
      final apiClient = ApiClient();
      final authService = AuthService();
      final user = await authService.getCurrentUser();
      
      if (user != null && user.restaurantId != null) {
        final restaurant = await apiClient.get('/restaurants/${user.restaurantId}', requiresAuth: false);
        setState(() {
          _restaurantData = restaurant;
          _restaurantLoaded = true;
        });
        // Load menu items after restaurant data is available
        _loadMenuItems();
      } else {
        setState(() {
          _restaurantLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading restaurant data: $e');
      setState(() {
        _restaurantLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Restaurant Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.shopping_bag), text: 'Orders'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Earnings'),
              Tab(icon: Icon(Icons.restaurant_menu), text: 'My Restaurant'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                ref.refresh(orderProvider);
                _loadCommissions();
                _loadRestaurantData();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildOrdersTab(ordersAsync),
            _buildEarningsTab(),
            _buildRestaurantDetailsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(AsyncValue ordersAsync) {
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id?.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM d, HH:mm').format(order.createdAt ?? DateTime.now()),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Customer: ${order.userName ?? "Unknown"}'),
                    if (order.userPhone != null) Text('Phone: ${order.userPhone}'),
                    const SizedBox(height: 12),
                    
                    // Order Items
                    const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (order.items != null && order.items!.isNotEmpty) ...[
                      ...order.items!.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${item.quantity}x ${item.name}'),
                            ),
                            Text('₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                          ],
                        ),
                      )),
                      const Divider(),
                    ],
                    
                    Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Status: '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _mapToRestaurantStatus(order.status),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Order Accepted')),
                              DropdownMenuItem(value: 'preparing', child: Text('Preparation')),
                              DropdownMenuItem(value: 'rider_assigned', child: Text('HandOver')),
                              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                            ],
                            onChanged: (newStatus) {
                              if (newStatus != null && newStatus != order.status) {
                                ref.read(orderProvider.notifier).updateStatus(order.id!, newStatus);
                              }
                            },
                          ),
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
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildEarningsTab() {
    if (!_commissionsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Total Earnings',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${_totalEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _commissions.isEmpty
              ? const Center(child: Text('No commissions yet'))
              : ListView.builder(
                  itemCount: _commissions.length,
                  itemBuilder: (context, index) {
                    final commission = _commissions[index];
                    final isPending = commission['status'] == 'pending';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text('${commission['percentage']}%'),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text('Order #${commission['order_id'].toString().substring(0, 8)}')),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPending ? Colors.orange : Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPending ? 'PENDING' : 'APPROVED',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy').format(
                            DateTime.parse(commission['created_at']),
                          ),
                        ),
                        trailing: Text(
                          '₹${double.parse(commission['amount'].toString()).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _mapToRestaurantStatus(String status) {
    // Map backend status to restaurant-friendly status
    // This ensures the dropdown shows the correct value
    if (status == 'delivered') {
      return 'rider_assigned'; // Show as HandOver if already delivered
    }
    return status;
  }

  Widget _buildRestaurantDetailsTab() {
    if (!_restaurantLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_restaurantData == null) {
      return const Center(
        child: Text('No restaurant assigned to your account'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Restaurant Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _editRestaurant(_restaurantData!['id']),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Name', _restaurantData!['name'] ?? 'N/A'),
                  _buildDetailRow('Cuisine', _restaurantData!['cuisine'] ?? 'N/A'),
                  _buildDetailRow('Address', _restaurantData!['address'] ?? 'N/A'),
                  _buildDetailRow('Phone', _restaurantData!['phone'] ?? 'N/A'),
                  _buildDetailRow('Rating', _restaurantData!['rating']?.toString() ?? 'N/A'),
                  _buildDetailRow('Delivery Time', _restaurantData!['delivery_time'] ?? 'N/A'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Menu Items Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Menu Items',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addMenuItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_menuItemsLoaded)
            const Center(child: CircularProgressIndicator())
          else if (_menuItems.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No menu items yet. Add your first item!'),
                ),
              ),
            )
          else
            ..._menuItems.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item['name'] ?? ''),
                    subtitle: Text(item['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${item['price']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editMenuItem(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMenuItem(item['id']),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editRestaurant(String restaurantId) async {
    try {
      // Fetch current restaurant details
      final apiClient = ApiClient();
      final restaurant = _restaurantData!;

      if (!mounted) return;

      // Controllers for text fields
      final nameController = TextEditingController(text: restaurant['name'] ?? '');
      final cuisineController = TextEditingController(text: restaurant['cuisine'] ?? '');
      final addressController = TextEditingController(text: restaurant['address'] ?? '');
      final phoneController = TextEditingController(text: restaurant['phone'] ?? '');
      String? uploadedImageUrl = restaurant['image_url'];
      final latController = TextEditingController(text: restaurant['latitude']?.toString() ?? '');
      final lngController = TextEditingController(text: restaurant['longitude']?.toString() ?? '');

      // Show edit dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Restaurant Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cuisineController,
                  decoration: const InputDecoration(
                    labelText: 'Cuisine',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ImagePickerWidget(
                  initialImageUrl: uploadedImageUrl,
                  onImageUploaded: (url) {
                    uploadedImageUrl = url;
                  },
                  label: 'Restaurant Image',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: lngController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    try {
                      final position = await Geolocator.getCurrentPosition();
                      latController.text = position.latitude.toString();
                      lngController.text = position.longitude.toString();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error getting location: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Pin Current Location'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (result == true && mounted) {
        // Prepare update data
        final updateData = <String, dynamic>{};
        if (nameController.text.isNotEmpty) updateData['name'] = nameController.text;
        if (cuisineController.text.isNotEmpty) updateData['cuisine'] = cuisineController.text;
        if (addressController.text.isNotEmpty) updateData['address'] = addressController.text;
        if (phoneController.text.isNotEmpty) updateData['phone'] = phoneController.text;
        if (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty) updateData['image_url'] = uploadedImageUrl;
        if (latController.text.isNotEmpty) updateData['latitude'] = double.tryParse(latController.text);
        if (lngController.text.isNotEmpty) updateData['longitude'] = double.tryParse(lngController.text);

        // Send PUT request
        await apiClient.put(
          '/restaurants/$restaurantId',
          body: updateData,
          requiresAuth: true,
        );

        // Reload data
        _loadRestaurantData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restaurant updated successfully')),
          );
        }
      }

      // Dispose controllers
      nameController.dispose();
      cuisineController.dispose();
      addressController.dispose();
      phoneController.dispose();
      latController.dispose();
      lngController.dispose();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      if (_restaurantData == null) return;
      
      final apiClient = ApiClient();
      final items = await apiClient.get('/restaurants/${_restaurantData!['id']}/menu', requiresAuth: false);
      setState(() {
        _menuItems = List<Map<String, dynamic>>.from(items ?? []);
        _menuItemsLoaded = true;
      });
    } catch (e) {
      print('Error loading menu items: $e');
      setState(() {
        _menuItemsLoaded = true;
      });
    }
  }


  Future<void> _addMenuItem() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String? uploadedImageUrl;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Menu Item', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue))),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price *', border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue))),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ImagePickerWidget(
                initialImageUrl: uploadedImageUrl,
                onImageUploaded: (url) {
                  uploadedImageUrl = url;
                },
                label: 'Menu Item Image',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel'), style: TextButton.styleFrom(foregroundColor: primaryBlue)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add'), style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white)),
        ],
      ),
    );

    if (result == true && mounted) {
      if (nameController.text.isEmpty || priceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name and price are required')),
        );
        return;
      }

      try {
        final apiClient = ApiClient();
        await apiClient.post(
          '/menu-items',
          body: {
            'restaurant_id': _restaurantData!['id'],
            'name': nameController.text,
            'description': descriptionController.text,
            'price': double.parse(priceController.text),
            'image_url': uploadedImageUrl ?? '',
          },
          requiresAuth: true,
        );
        _loadMenuItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu item added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    // imageUrlController removed
  }

  Future<void> _editMenuItem(Map<String, dynamic> item) async {
    final nameController = TextEditingController(text: item['name']);
    final descriptionController = TextEditingController(text: item['description']);
    final priceController = TextEditingController(text: item['price'].toString());
    String? uploadedImageUrl = item['image_url'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Menu Item', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue))),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue))),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ImagePickerWidget(
                initialImageUrl: uploadedImageUrl,
                onImageUploaded: (url) {
                  uploadedImageUrl = url;
                },
                label: 'Menu Item Image',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel'), style: TextButton.styleFrom(foregroundColor: primaryBlue)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'), style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white)),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final apiClient = ApiClient();
        await apiClient.put(
          '/menu-items/${item['id']}',
          body: {
            'name': nameController.text,
            'description': descriptionController.text,
            'price': double.parse(priceController.text),
            'image_url': uploadedImageUrl ?? item['image_url'],
          },
          requiresAuth: true,
        );
        _loadMenuItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu item updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    // imageUrlController removed
  }

  Future<void> _deleteMenuItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final apiClient = ApiClient();
        await apiClient.delete('/menu-items/$itemId', requiresAuth: true);
        _loadMenuItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu item deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}


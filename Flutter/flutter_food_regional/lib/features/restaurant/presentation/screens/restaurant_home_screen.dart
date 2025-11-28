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
  
  
  
  
  
  
  
  List<Map<String, dynamic>> _commissions = [];
  double _totalEarnings = 0.0;
  bool _commissionsLoaded = false;
  Map<String, dynamic>? _restaurantData;
  bool _restaurantLoaded = false;
  List<Map<String, dynamic>> _menuItems = [];
  bool _menuItemsLoaded = false;
  int _selectedIndex = 0;

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background header with cloud divider
          _buildHeader(),
          
          // Content with IndexedStack
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildOrdersTab(ordersAsync),
                _buildEarningsTab(),
                _buildRestaurantDetailsTab(),
              ],
            ),
          ),
          
          // Top AppBar with interactive elements
          _buildAppBar(),
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
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'My Restaurant',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                      Icons.restaurant,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Restaurant Dashboard',
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

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Restaurant Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    ref.refresh(orderProvider);
                    _loadCommissions();
                    _loadRestaurantData();
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

  Widget _buildOrdersTab(AsyncValue ordersAsync) {
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(child: Text('No orders found'));
        }
        return ListView.builder(
          itemCount: orders.length,
          padding: EdgeInsets.only(top: 320, bottom: 20),
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id?.substring(0, 8)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM d, HH:mm').format(order.createdAt ?? DateTime.now()),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Customer: ${order.userName ?? "Unknown"}'),
                    if (order.userPhone != null) Text('Phone: ${order.userPhone}'),
                    SizedBox(height: 12),
                    
                    // Order Items
                    Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    if (order.items != null && order.items!.isNotEmpty) ...[
                      ...order.items!.map((item) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
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
                      Divider(),
                    ],
                    
                    Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Status: '),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _mapToRestaurantStatus(order.status),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(value: 'pending', child: Text('Order Accepted')),
                              DropdownMenuItem(value: 'preparing', child: Text('Preparation')),
                              DropdownMenuItem(value: 'handover', child: Text('Hand Over')),
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
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildEarningsTab() {
    if (!_commissionsLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 320, bottom: 20),
      itemCount: _commissions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Summary Card
          return Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.all(16),
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
                Text(
                  'Total Earnings',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '₹${_totalEarnings.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        if (_commissions.isEmpty) {
          return Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No commissions yet'),
          ));
        }

        final commission = _commissions[index - 1];
        final status = commission['status'];
        final isRejected = status == 'rejected';
        final isPending = status == 'pending';
        final isApproved = status == 'approved';
        
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text('${commission['percentage']}%'),
            ),
            title: Row(
              children: [
                Expanded(child: Text('Order #${commission['order_id'].toString().substring(0, 8)}')),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRejected ? Colors.red : (isPending ? Colors.orange : Colors.green),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isRejected ? 'REJECTED' : (isPending ? 'PENDING' : 'APPROVED'),
                    style: TextStyle(color: Colors.white, fontSize: 10),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange,
              ),
            ),
          ),
        );
      },
    );
  }

  String _mapToRestaurantStatus(String status) {
    // Map backend status to restaurant-friendly status
    // This ensures the dropdown shows the correct value
    
    // Valid statuses in the dropdown
    const validStatuses = ['pending', 'preparing', 'handover', 'cancelled'];
    
    if (status == 'delivered') {
      return 'handover'; // Show as Hand Over if already delivered
    }
    
    if (status == 'rider_assigned') {
      return 'pending'; // Show as Order Accepted even if rider is assigned
    }
    
    if (validStatuses.contains(status)) {
      return status;
    }
    
    // Default to 'pending' (Order Accepted) for any other status
    return 'pending';
  }

  Widget _buildRestaurantDetailsTab() {
    if (!_restaurantLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    if (_restaurantData == null) {
      return Center(
        child: Text('No restaurant assigned to your account'),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 340, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Restaurant Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _editRestaurant(_restaurantData!['id']),
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),
                      ),
                    ],
                  ),
                  Divider(height: 24),
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
          SizedBox(height: 24),
          // Menu Items Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu Items',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addMenuItem,
                icon: Icon(Icons.add),
                label: Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (!_menuItemsLoaded)
            Center(child: CircularProgressIndicator())
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
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item['name'] ?? ''),
                    subtitle: Text(item['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${item['price']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editMenuItem(item),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
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
          title: Text('Edit Restaurant Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: cuisineController,
                  decoration: InputDecoration(
                    labelText: 'Cuisine',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                ImagePickerWidget(
                  initialImageUrl: uploadedImageUrl,
                  onImageUploaded: (url) {
                    uploadedImageUrl = url;
                  },
                  label: 'Restaurant Image',
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latController,
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: lngController,
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
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
                  icon: Icon(Icons.my_location),
                  label: Text('Pin Current Location'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Save'),
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
    bool isVeg = true; // Default to veg

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Menu Item', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name *', border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary))),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary))),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price *', border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary))),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                // Veg/Non-Veg Toggle
                Row(
                  children: [
                    Text('Food Type:', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isVeg = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isVeg ? Colors.green : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 16,
                          color: isVeg ? Colors.white : Colors.green,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isVeg = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: !isVeg ? Colors.red : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 16,
                          color: !isVeg ? Colors.white : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
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
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel'), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary)),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Add'), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white)),
          ],
        ),
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
            'is_veg': isVeg ? 1 : 0,
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
    bool isVeg = item['is_veg'] == 1 || item['is_veg'] == true; // Get existing value

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Menu Item', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary))),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary))),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary))),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                // Veg/Non-Veg Toggle
                Row(
                  children: [
                    Text('Food Type:', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isVeg = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isVeg ? Colors.green : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 16,
                          color: isVeg ? Colors.white : Colors.green,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isVeg = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: !isVeg ? Colors.red : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 16,
                          color: !isVeg ? Colors.white : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
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
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel'), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary)),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Save'), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white)),
          ],
        ),
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
            'is_veg': isVeg ? 1 : 0,
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
        title: Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
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

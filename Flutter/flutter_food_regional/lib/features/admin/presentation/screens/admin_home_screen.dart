import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../orders/data/providers/order_provider.dart';
import '../../../orders/data/services/order_service.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/presentation/widgets/image_picker_widget.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  List<Map<String, dynamic>> _riders = [];
  List<Map<String, dynamic>> _restaurantOwners = [];
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _commissions = [];
  double _totalCommissions = 0.0;
  bool _ridersLoaded = false;
  bool _ownersLoaded = false;
  bool _restaurantsLoaded = false;
  bool _commissionsLoaded = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRiders();
    _loadRestaurantOwners();
    _loadRestaurants();
    _loadCommissions();
  }

  Future<void> _loadRiders() async {
    try {
      final orderService = OrderService(ApiClient());
      final riders = await orderService.getRiders();
      setState(() {
        _riders = riders;
        _ridersLoaded = true;
      });
    } catch (e) {
      print('Error loading riders: $e');
      setState(() {
        _ridersLoaded = true;
      });
    }
  }

  Future<void> _loadRestaurantOwners() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/users/restaurant-owners', requiresAuth: true);
      setState(() {
        _restaurantOwners = List<Map<String, dynamic>>.from(response ?? []);
        _ownersLoaded = true;
      });
    } catch (e) {
      print('Error loading restaurant owners: $e');
      setState(() {
        _ownersLoaded = true;
      });
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/restaurants', requiresAuth: false);
      setState(() {
        _restaurants = List<Map<String, dynamic>>.from(response ?? []);
        _restaurantsLoaded = true;
      });
    } catch (e) {
      print('Error loading restaurants: $e');
      setState(() {
        _restaurantsLoaded = true;
      });
    }
  }

  Future<void> _loadCommissions() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/commissions', requiresAuth: true);
      setState(() {
        _commissions = List<Map<String, dynamic>>.from(response['commissions'] ?? []);
        _totalCommissions = double.tryParse(response['total']?.toString() ?? '0') ?? 0.0;
        _commissionsLoaded = true;
      });
    } catch (e) {
      print('Error loading commissions: $e');
      setState(() {
        _commissionsLoaded = true;
      });
    }
  }

  Future<void> _assignRestaurant(String userId, String? restaurantId) async {
    try {
      final apiClient = ApiClient();
      await apiClient.put(
        '/users/$userId/assign-restaurant',
        body: {'restaurantId': restaurantId},
        requiresAuth: true,
      );
      _loadRestaurantOwners(); // Reload to show updated data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant assigned successfully')),
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

  Future<void> _approveCommission(String commissionId) async {
    try {
      final apiClient = ApiClient();
      await apiClient.put(
        '/commissions/$commissionId/approve',
        body: {},
        requiresAuth: true,
      );
      _loadCommissions(); // Reload to show updated status
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commission approved successfully')),
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

  Future<void> _rejectCommission(String commissionId) async {
    try {
      final apiClient = ApiClient();
      await apiClient.put(
        '/commissions/$commissionId/reject',
        body: {},
        requiresAuth: true,
      );
      _loadCommissions(); // Reload to show updated status
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commission rejected successfully')),
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

  Future<void> _editRestaurant(String restaurantId) async {
    try {
      // Fetch current restaurant details
      final apiClient = ApiClient();
      final restaurant = await apiClient.get('/restaurants/$restaurantId', requiresAuth: false);

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
          title: Text('Edit Restaurant Details', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: cuisineController,
                  decoration: InputDecoration(
                    labelText: 'Cuisine',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
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
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
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
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
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
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Save'), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white)),
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
        _loadRestaurantOwners();
        _loadRestaurants();

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

  Future<void> _addRestaurant() async {
    // Controllers for text fields
    final nameController = TextEditingController();
    final cuisineController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    String? uploadedImageUrl;
    final ratingController = TextEditingController(text: '4.0');
    final deliveryTimeController = TextEditingController(text: '30-40 min');
    final latController = TextEditingController();
    final lngController = TextEditingController();

    try {
      // Show add dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add New Restaurant', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: cuisineController,
                  decoration: InputDecoration(
                    labelText: 'Cuisine *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
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
                TextField(
                  controller: ratingController,
                  decoration: InputDecoration(
                    labelText: 'Rating',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: deliveryTimeController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Time',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latController,
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
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
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
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
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Create'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      );

      if (result == true && mounted) {
        // Validate required fields
        if (nameController.text.isEmpty || cuisineController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name and cuisine are required')),
          );
          return;
        }

        // Prepare data
        final newRestaurantData = <String, dynamic>{
          'name': nameController.text,
          'cuisine': cuisineController.text,
        };
        
        if (addressController.text.isNotEmpty) newRestaurantData['address'] = addressController.text;
        if (phoneController.text.isNotEmpty) newRestaurantData['phone'] = phoneController.text;
        if (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty) newRestaurantData['image_url'] = uploadedImageUrl;
        if (ratingController.text.isNotEmpty) {
          newRestaurantData['rating'] = double.tryParse(ratingController.text) ?? 4.0;
        }
        if (deliveryTimeController.text.isNotEmpty) {
          newRestaurantData['delivery_time'] = deliveryTimeController.text;
        }
        if (latController.text.isNotEmpty) newRestaurantData['latitude'] = double.tryParse(latController.text);
        if (lngController.text.isNotEmpty) newRestaurantData['longitude'] = double.tryParse(lngController.text);

        // Send POST request
        final apiClient = ApiClient();
        await apiClient.post(
          '/restaurants',
          body: newRestaurantData,
          requiresAuth: true,
        );

        // Reload data
        _loadRestaurantOwners();
        _loadRestaurants();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restaurant created successfully')),
          );
        }
      }

      // Dispose controllers
      nameController.dispose();
      cuisineController.dispose();
      addressController.dispose();
      phoneController.dispose();
      ratingController.dispose();
      deliveryTimeController.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                _buildOrdersTab(),
                _buildRestaurantsTab(),
                _buildCommissionsTab(),
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
            icon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Commissions',
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
                      Icons.admin_panel_settings,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Admin Dashboard',
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
            Text(
              'Admin Dashboard',
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
                    _loadRiders();
                    _loadRestaurantOwners();
                    _loadRestaurants();
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

  Widget _buildOrdersTab() {
    final ordersAsync = ref.watch(orderProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(child: Text('No orders found'));
        }
        return ListView.builder(
          itemCount: orders.length,
          padding: EdgeInsets.only(top: 280, bottom: 20),
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    SizedBox(height: 8),
                    Text('Customer: ${order.userName ?? "Unknown"}'),
                    Text('Restaurant: ${order.restaurantName ?? "Unknown"}'),
                    Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Status: '),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: order.status,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'preparing', child: Text('Preparing')),
                              DropdownMenuItem(value: 'rider_assigned', child: Text('Rider Assigned')),
                              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
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
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Rider: '),
                        SizedBox(width: 8),
                        Expanded(
                          child: _ridersLoaded
                              ? DropdownButtonFormField<String>(
                                  value: order.riderId,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  hint: Text('Assign Rider'),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('No Rider')),
                                    ..._riders.map((rider) => DropdownMenuItem(
                                          value: rider['id'] as String,
                                          child: Text(rider['name'] as String),
                                        )),
                                  ],
                                  onChanged: (newRiderId) {
                                    if (newRiderId != null && newRiderId != order.riderId) {
                                      ref.read(orderProvider.notifier).assignRider(order.id!, newRiderId);
                                    }
                                  },
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ],
                    ),
                    if (order.riderName != null) ...[
                      SizedBox(height: 8),
                      Text('Assigned to: ${order.riderName}', style: const TextStyle(color: Colors.green)),
                    ],
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

  Widget _buildRestaurantsTab() {
    if (!_ownersLoaded || !_restaurantsLoaded) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No restaurants found'),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addRestaurant,
              icon: Icon(Icons.add),
              label: Text('Add First Restaurant'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          itemCount: _restaurants.length,
          padding: EdgeInsets.only(top: 280, bottom: 80),
          itemBuilder: (context, index) {
            final restaurant = _restaurants[index];
            final restaurantId = restaurant['id'];
            
            // Find the owner assigned to this restaurant
            final assignedOwner = _restaurantOwners.firstWhere(
              (owner) => owner['restaurant_id'] == restaurantId,
              orElse: () => <String, dynamic>{},
            );

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                restaurant['cuisine'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          tooltip: 'Edit Restaurant',
                          onPressed: () => _editRestaurant(restaurantId),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    if (restaurant['address'] != null && restaurant['address'].toString().isNotEmpty) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant['address'],
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (restaurant['phone'] != null && restaurant['phone'].toString().isNotEmpty) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            restaurant['phone'],
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 12),
                    Divider(),
                    SizedBox(height: 8),
                    Text(
                      'Assigned Owner:',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: assignedOwner['id'],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      hint: Text('Select Owner'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('No Owner')),
                        ..._restaurantOwners.map((owner) => DropdownMenuItem(
                              value: owner['id'],
                              child: Text('${owner['name']} (${owner['email']})'),
                            )),
                      ],
                      onChanged: (newOwnerId) {
                        if (newOwnerId != null) {
                          _assignRestaurant(newOwnerId, restaurantId);
                        }
                      },
                    ),
                    if (assignedOwner.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.green.shade700),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Managed by: ${assignedOwner['name']}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _manageMenuItems(restaurantId, restaurant['name']),
                      icon: Icon(Icons.restaurant_menu, size: 16),
                      label: Text('Manage Menu Items', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _addRestaurant,
            icon: Icon(Icons.add),
            label: Text('Add Restaurant'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionsTab() {
    if (!_commissionsLoaded) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 340, left: 20, right: 20, bottom: 20),
      itemCount: _commissions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Summary Card
          return Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.all(16),
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
                  'Total Commissions Paid',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '₹${_totalCommissions.toStringAsFixed(2)}',
                  style: const TextStyle(
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
        final isRider = commission['user_role'] == 'rider';
        final isPending = commission['status'] == 'pending';
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: isRider ? Colors.green : Colors.orange,
              child: Icon(
                isRider ? Icons.delivery_dining : Icons.restaurant,
                color: Colors.white,
              ),
            ),
            title: Text(commission['user_name'] ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${commission['order_id'].toString().substring(0, 8)}'),
                Text(
                  DateFormat('MMM d, yyyy').format(
                    DateTime.parse(commission['created_at']),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${double.parse(commission['amount'].toString()).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isRider ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      '${commission['percentage']}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                if (isPending) ...[
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _approveCommission(commission['id']),
                    tooltip: 'Approve',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _rejectCommission(commission['id']),
                    tooltip: 'Reject',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ] else ...[
                  Text(
                    commission['status'] == 'approved' ? 'Approved' : 'Rejected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: commission['status'] == 'approved' ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

  }

  Future<void> _manageMenuItems(String restaurantId, String restaurantName) async {
    // Load menu items for this restaurant
    final apiClient = ApiClient();
    List<Map<String, dynamic>> menuItems = [];
    
    try {
      final items = await apiClient.get('/restaurants/$restaurantId/menu', requiresAuth: false);
      menuItems = List<Map<String, dynamic>>.from(items ?? []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading menu items: $e')),
        );
      }
      return;
    }

    if (!mounted) return;

    // Show dialog with menu items
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Menu Items - $restaurantName', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: menuItems.isEmpty
                ? Center(child: Text('No menu items yet'))
                : ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item['name'] ?? ''),
                          subtitle: Text(item['description'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary, size: 20),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _editMenuItemForRestaurant(item, restaurantId);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () async {
                                  try {
                                    await apiClient.delete('/menu-items/${item['id']}', requiresAuth: true);
                                    final updatedItems = await apiClient.get('/restaurants/$restaurantId/menu', requiresAuth: false);
                                    setState(() {
                                      menuItems = List<Map<String, dynamic>>.from(updatedItems ?? []);
                                    });
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _addMenuItemForRestaurant(restaurantId);
              },
              icon: Icon(Icons.add),
              label: Text('Add Item'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMenuItemForRestaurant(String restaurantId) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String? uploadedImageUrl;
    bool isVeg = true;

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
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
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
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Add'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            ),
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
            'restaurant_id': restaurantId,
            'name': nameController.text,
            'description': descriptionController.text,
            'price': double.parse(priceController.text),
            'image_url': uploadedImageUrl ?? '',
            'is_veg': isVeg ? 1 : 0,
          },
          requiresAuth: true,
        );
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
  }

  Future<void> _editMenuItemForRestaurant(Map<String, dynamic> item, String restaurantId) async {
    final nameController = TextEditingController(text: item['name']);
    final descriptionController = TextEditingController(text: item['description']);
    final priceController = TextEditingController(text: item['price'].toString());
    String? uploadedImageUrl = item['image_url'];
    bool isVeg = item['is_veg'] == 1 || item['is_veg'] == true;

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
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
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
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Save'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            ),
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

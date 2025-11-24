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
  // Modern color palette
  static const Color primaryBlue = Color(0xFF5BA3D0);
  static const Color backgroundColor = Color(0xFFF5F9FC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentOrange = Color(0xFFFF6B6B);
  
  List<Map<String, dynamic>> _riders = [];
  List<Map<String, dynamic>> _restaurantOwners = [];
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _commissions = [];
  double _totalCommissions = 0.0;
  bool _ridersLoaded = false;
  bool _ownersLoaded = false;
  bool _restaurantsLoaded = false;
  bool _commissionsLoaded = false;

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
          title: const Text('Edit Restaurant Details', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cuisineController,
                  decoration: const InputDecoration(
                    labelText: 'Cuisine',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue)),
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
                          border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue)),
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
                          border: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue)),
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
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save'), style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white)),
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
          title: const Text('Add New Restaurant', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant Name *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cuisineController,
                  decoration: const InputDecoration(
                    labelText: 'Cuisine *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
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
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Rating',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deliveryTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Time',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryBlue),
                          ),
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
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryBlue),
                          ),
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
              style: TextButton.styleFrom(foregroundColor: primaryBlue),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.shopping_bag), text: 'Orders'),
              Tab(icon: Icon(Icons.restaurant), text: 'Restaurants'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Commissions'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                ref.refresh(orderProvider);
                _loadRiders();
                _loadRestaurantOwners();
                _loadRestaurants();
                _loadCommissions();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
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
            _buildOrdersTab(),
            _buildRestaurantsTab(),
            _buildCommissionsTab(),
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
          return const Center(child: Text('No orders found'));
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Text('Restaurant: ${order.restaurantName ?? "Unknown"}'),
                    Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Status: '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: order.status,
                            decoration: const InputDecoration(
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Rider: '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ridersLoaded
                              ? DropdownButtonFormField<String>(
                                  value: order.riderId,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  hint: const Text('Assign Rider'),
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
                      const SizedBox(height: 8),
                      Text('Assigned to: ${order.riderName}', style: const TextStyle(color: Colors.green)),
                    ],
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

  Widget _buildRestaurantsTab() {
    if (!_ownersLoaded || !_restaurantsLoaded) {
      return const Center(child: CircularProgressIndicator(color: primaryBlue));
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No restaurants found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addRestaurant,
              icon: const Icon(Icons.add),
              label: const Text('Add First Restaurant'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          itemCount: _restaurants.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            final restaurant = _restaurants[index];
            final restaurantId = restaurant['id'];
            
            // Find the owner assigned to this restaurant
            final assignedOwner = _restaurantOwners.firstWhere(
              (owner) => owner['restaurant_id'] == restaurantId,
              orElse: () => <String, dynamic>{},
            );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              const SizedBox(height: 4),
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
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Restaurant',
                          onPressed: () => _editRestaurant(restaurantId),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    if (restaurant['address'] != null && restaurant['address'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            restaurant['phone'],
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Assigned Owner:',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: assignedOwner['id'],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      hint: const Text('Select Owner'),
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 8),
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
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _manageMenuItems(restaurantId, restaurant['name']),
                      icon: const Icon(Icons.restaurant_menu, size: 16),
                      label: const Text('Manage Menu Items', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            icon: const Icon(Icons.add),
            label: const Text('Add Restaurant'),
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionsTab() {
    if (!_commissionsLoaded) {
      return const Center(child: CircularProgressIndicator(color: primaryBlue));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
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
                'Total Commissions Paid',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
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
        ),
        Expanded(
          child: _commissions.isEmpty
              ? const Center(child: Text('No commissions yet'))
              : ListView.builder(
                  itemCount: _commissions.length,
                  itemBuilder: (context, index) {
                    final commission = _commissions[index];
                    final isRider = commission['user_role'] == 'rider';
                    final isPending = commission['status'] == 'pending';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: isRider ? Colors.green : Colors.orange,
                          child: Icon(
                            isRider ? Icons.delivery_dining : Icons.restaurant,
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(commission['user_name'] ?? 'Unknown')),
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
                            if (isPending)
                              TextButton(
                                onPressed: () => _approveCommission(commission['id']),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 20),
                                ),
                                child: const Text('Approve', style: TextStyle(fontSize: 10)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
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
          title: Text('Menu Items - $restaurantName', style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: menuItems.isEmpty
                ? const Center(child: Text('No menu items yet'))
                : ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item['name'] ?? ''),
                          subtitle: Text(item['description'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
              child: const Text('Close'),
              style: TextButton.styleFrom(foregroundColor: primaryBlue),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _addMenuItemForRestaurant(restaurantId);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
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
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                  maxLines: 2,
                ),
              const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price *',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: primaryBlue),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
          ),
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
            'restaurant_id': restaurantId,
            'name': nameController.text,
            'description': descriptionController.text,
            'price': double.parse(priceController.text),
            'image_url': uploadedImageUrl ?? '',
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
}

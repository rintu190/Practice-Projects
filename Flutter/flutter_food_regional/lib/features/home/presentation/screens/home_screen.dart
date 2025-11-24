import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/providers/restaurant_provider.dart';
import '../../../profile/data/providers/address_provider.dart';
import '../../../profile/data/providers/selected_address_provider.dart';
import '../../../profile/data/models/address.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantListProvider(_selectedCategory == 'All' ? null : _selectedCategory));
    final addressesAsync = ref.watch(addressProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryGradientTop,
                  AppTheme.primaryGradientBottom,
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header Area (Transparent on top of gradient)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              addressesAsync.whenData((addresses) {
                                if (addresses.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No addresses found. Please add an address first.')),
                                  );
                                  context.push('/profile/addresses');
                                } else {
                                  _showAddressSelectionDialog(addresses);
                                }
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deliver to',
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                ),
                                addressesAsync.when(
                                  data: (addresses) {
                                    // Set default address if not selected
                                    if (selectedAddress == null && addresses.isNotEmpty) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        // Prefer default address, otherwise use first
                                        final defaultAddr = addresses.firstWhere(
                                          (addr) => addr.isDefault,
                                          orElse: () => addresses.first,
                                        );
                                        ref.read(selectedAddressProvider.notifier).selectAddress(defaultAddr);
                                      });
                                    }
                                    
                                    final displayText = selectedAddress?.label ?? 
                                                       (addresses.isNotEmpty ? addresses.firstWhere(
                                                         (addr) => addr.isDefault,
                                                         orElse: () => addresses.first,
                                                       ).label : 'Add Address');
                                    
                                    return Row(
                                      children: [
                                        Text(
                                          displayText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                      ],
                                    );
                                  },
                                  loading: () => const Row(
                                    children: [
                                      Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                    ],
                                  ),
                                  error: (_, __) => const Row(
                                    children: [
                                      Text(
                                        'Add Address',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                                image: user?.profilePicture != null
                                    ? DecorationImage(
                                        image: NetworkImage('${ApiConstants.serverUrl}${user!.profilePicture}'),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: user?.profilePicture == null
                                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search Bar
                      GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey[400]),
                              const SizedBox(width: 12),
                              Text(
                                'Find your favorite food...',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // White Overlay Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Categories
                            Text(
                              'Explore Regions',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildCategoryItem('All', Icons.grid_view, 'All'),
                                  _buildCategoryItem('North', Icons.rice_bowl, 'North'),
                                  _buildCategoryItem('South', Icons.local_dining, 'South'),
                                  _buildCategoryItem('Odisha', Icons.temple_buddhist, 'Odisha'),
                                  _buildCategoryItem('Fast Food', Icons.fastfood, 'Fast Food'),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Popular Restaurants
                            Text(
                              'Popular Near You',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Handle async restaurant data
                            restaurantsAsync.when(
                              data: (restaurants) => ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: restaurants.length,
                                itemBuilder: (context, index) {
                                  final restaurant = restaurants[index];
                                  return GestureDetector(
                                    onTap: () => context.push('/restaurant/${restaurant.id}'),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity( 0.05),
                                            blurRadius: 20,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                        border: Border.all(color: Colors.grey.withOpacity( 0.1)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Image
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                                child: Image.network(
                                                  restaurant.imageUrl,
                                                  height: 180,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 16,
                                                right: 16,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        restaurant.rating.toString(),
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 16,
                                                left: 16,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity( 0.9),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    restaurant.deliveryTime,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                      color: Color(0xFF6C63FF),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Info
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  restaurant.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  restaurant.cuisine,
                                                  style: TextStyle(color: Colors.grey[500]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
                                },
                              ),
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6C63FF),
                                  ),
                                ),
                              ),
                              error: (error, stack) => Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading restaurants',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        error.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => ref.refresh(restaurantListProvider(_selectedCategory == 'All' ? null : _selectedCategory)),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF6C63FF).withOpacity( 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF6C63FF)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: Color(0xFF6C63FF)),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: Color(0xFF6C63FF)),
            label: 'Cart',
          ),
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push('/search');
              break;
            case 2:
              context.push('/cart');
              break;
          }
        },
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity( 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).slideX(),
    );
  }

  void _showAddressSelectionDialog(List<Address> addresses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Delivery Address'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              final selectedAddress = ref.watch(selectedAddressProvider);
              final isSelected = selectedAddress?.id == address.id;
              
              return ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: isSelected ? AppTheme.primaryOrange : Colors.grey,
                ),
                title: Text(
                  address.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${address.houseNumber}, ${address.locality}\n${address.city}, ${address.state} - ${address.pincode}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppTheme.primaryOrange)
                    : null,
                onTap: () {
                  ref.read(selectedAddressProvider.notifier).selectAddress(address);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.push('/profile/addresses');
              Navigator.pop(context);
            },
            child: const Text('Add New Address'),
          ),
        ],
      ),
    );
  }
}

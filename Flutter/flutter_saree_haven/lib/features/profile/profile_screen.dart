import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/data/api_repository.dart';
import '../auth/auth_service.dart';
import 'my_orders_screen.dart';
import 'wishlist_screen.dart';
import 'shipping_addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import '../seller/edit_shop_profile_screen.dart';
import '../../core/widgets/saree_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom Gradient Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Consumer<AuthService>(
                builder: (context, auth, _) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              Color(0xFF7B5FE7),
                              Color(0xFF9B7FFF),
                            ],
                          ),
                        ),
                      ),
                      // Abstract decorative circles
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // Profile Info
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: (auth.userImageUrl != null && auth.userImageUrl!.isNotEmpty)
                                  ? SareeImage(imageUrl: auth.userImageUrl!, fit: BoxFit.cover)
                                  : Container(
                                      color: Colors.white,
                                      child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            auth.userName ?? 'User Name',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            auth.userEmail ?? 'user@example.com',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Stats Cards and Sections
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Consumer<AuthService>(
                builder: (context, auth, _) {
                  return Column(
                    children: [
                      // Stats Area
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: auth.userId != null ? ApiRepository.getUserStats(auth.userId!) : null,
                          builder: (context, snap) {
                            final stats = snap.data;
                            final orders = stats?['ordersCount']?.toString() ?? '...';
                            final wishlist = stats?['wishlistCount']?.toString() ?? '...';
                            final wallet = stats?['walletBalance']?.toString() ?? '...';
                            
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _StatCard(label: 'Orders', value: orders, icon: Icons.shopping_bag_outlined),
                                _StatCard(label: 'Wishlist', value: wishlist, icon: Icons.favorite_border),
                                _StatCard(label: 'Wallet', value: '₹$wallet', icon: Icons.account_balance_wallet_outlined),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Menu Sections
                      _buildSectionHeader('MY ACTIVITY'),
                      _buildActionItem(Icons.shopping_bag_outlined, 'My Orders', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
                      }),
                      _buildActionItem(Icons.favorite_border, 'Wishlist', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                      }),

                      const SizedBox(height: 16),
                       _buildSectionHeader('ACCOUNT SETTINGS'),
                       if (auth.role == UserRole.seller)
                         _buildActionItem(Icons.storefront_outlined, 'Edit Shop Profile', () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => const EditShopProfileScreen()));
                         }),
                       _buildActionItem(Icons.location_on_outlined, 'Shipping Addresses', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingAddressesScreen()));
                      }),
                      _buildActionItem(Icons.payment, 'Payment Methods', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
                      }),
                      _buildActionItem(Icons.settings_outlined, 'Settings', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      }),

                      const SizedBox(height: 16),
                      _buildSectionHeader('SUPPORT & LEGAL'),
                      _buildActionItem(Icons.help_outline, 'Help Center', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                      }),
                      _buildActionItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                      }),
                      _buildActionItem(Icons.description_outlined, 'Terms of Service', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()));
                      }),

                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => auth.logout(),
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            label: Text(
                              'Log Out',
                              style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 24, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

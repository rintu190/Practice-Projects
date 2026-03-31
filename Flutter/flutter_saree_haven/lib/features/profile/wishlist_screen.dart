import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/data/api_repository.dart';
import '../../core/models/saree_model.dart';
import '../auth/auth_service.dart';
import '../product_details/product_details_screen.dart';
import '../../core/widgets/saree_image.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<Saree>> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final userId = context.read<AuthService>().userId ?? '';
    _wishlistFuture = ApiRepository.getWishlist(userId);
  }

  Future<void> _removeFromWishlist(String sareeId) async {
    final userId = context.read<AuthService>().userId ?? '';
    try {
      await ApiRepository.removeFromWishlist(userId, sareeId);
      setState(() => _refresh());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Wishlist',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<List<Saree>>(
        future: _wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final wishlist = snapshot.data ?? [];

          if (wishlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Your wishlist is empty.',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              final saree = wishlist[index];
              return _buildWishlistItem(saree);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistItem(Saree saree) {
    final imageUrl = saree.imageUrls.isNotEmpty ? saree.imageUrls.first : '';
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailsScreen(saree: saree)),
        );
        setState(() => _refresh());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SareeImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeFromWishlist(saree.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration:
                            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(saree.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('₹${saree.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../api_config.dart';

class SareeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const SareeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorPlaceholder();
    }

    // Full Network URL
    if (imageUrl.startsWith('http')) {
      return _buildNetworkImage(imageUrl);
    }

    // Local Server Upload Path
    if (imageUrl.startsWith('uploads/')) {
      final fullUrl = '${ApiConfig.serverRootUrl}/$imageUrl';
      return _buildNetworkImage(fullUrl);
    }

    // App Asset
    if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
        );
    }

    // Treat anything else as potential server path if it has a dot or starts with store_ or saree_
    if (imageUrl.contains('.') || imageUrl.startsWith('store_') || imageUrl.startsWith('saree_')) {
      final fullUrl = imageUrl.contains('uploads/') 
          ? '${ApiConfig.serverRootUrl}/$imageUrl'
          : '${ApiConfig.serverRootUrl}/uploads/$imageUrl';
       return _buildNetworkImage(fullUrl);
    }

    return _buildErrorPlaceholder();
  }

  Widget _buildNetworkImage(String url) {
     return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
      );
  }

  Widget _buildErrorPlaceholder() {
    return errorWidget ?? Container(
        width: width,
        height: height,
        color: AppColors.background,
        child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
      );
  }
}

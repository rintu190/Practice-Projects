import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class ShippingAddressesScreen extends StatelessWidget {
  const ShippingAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Shipping Addresses', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAddressCard('Home', '123 Main Street, Phase 4\nSector 12, Chandigarh, 160012', true),
          const SizedBox(height: 16),
          _buildAddressCard('Office', 'Tech Park, Building 9\nCyber City, Gurugram, 122002', false),
          const SizedBox(height: 32),
          DottedBorderButton(
            onTap: () {},
            text: 'Add New Address',
            icon: Icons.add_location_alt_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String title, String details, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDefault ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(title == 'Home' ? Icons.home_outlined : Icons.work_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('Default', style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                )
            ],
          ),
          const SizedBox(height: 12),
          Text(details, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('Edit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.redAccent)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DottedBorderButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;

  const DottedBorderButton({super.key, required this.onTap, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import 'shipping_addresses_screen.dart'; // To reuse DottedBorderButton

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment Methods', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildPaymentCard('Visa', '**** **** **** 4892', '08/26', true),
          const SizedBox(height: 16),
          _buildPaymentCard('UPI', 'ayesha@upi', '', false),
          const SizedBox(height: 32),
          DottedBorderButton(
            onTap: () {},
            text: 'Add New Payment Method',
            icon: Icons.add_card,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String method, String details, String expiry, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: method == 'Visa' ? const LinearGradient(colors: [Color(0xFF2B32B2), Color(0xFF1488CC)]) : null,
        color: method != 'Visa' ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                method,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18, 
                  color: method == 'Visa' ? Colors.white : AppColors.textPrimary
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: method == 'Visa' ? Colors.white.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    'Default', 
                    style: GoogleFonts.poppins(
                      color: method == 'Visa' ? Colors.white : AppColors.primary, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w600
                    )
                  ),
                )
            ],
          ),
          const SizedBox(height: 24),
          Text(
            details, 
            style: GoogleFonts.robotoMono(
              fontSize: 18, 
              letterSpacing: 2,
              color: method == 'Visa' ? Colors.white : AppColors.textPrimary
            ),
          ),
          const SizedBox(height: 12),
          if (expiry.isNotEmpty)
            Text(
              'Exp: $expiry', 
              style: GoogleFonts.poppins(
                color: method == 'Visa' ? Colors.white70 : AppColors.textSecondary, 
                fontSize: 12
              )
            ),
        ],
      ),
    );
  }
}

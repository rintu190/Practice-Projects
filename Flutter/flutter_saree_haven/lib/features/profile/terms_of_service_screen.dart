import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Terms of Service',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. Introduction',
              'By accessing Saree Bazaar, you agree to comply with these Terms of Service. If you do not agree with any part of these terms, please refrain from using our services.',
            ),
            _buildSection(
              '2. User Accounts',
              'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account. We reserve the right to suspend accounts that violate our community guidelines.',
            ),
            _buildSection(
              '3. Marketplace Rules',
              'Sellers must provide accurate descriptions and high-quality images of their sarees. Buyers must provide valid payment information. All transactions must be completed through our secure checkout system.',
            ),
            _buildSection(
              '4. Intellectual Property',
              'All content on Saree Bazaar, including text, logos, and images, is the property of Saree Bazaar or its licensors and is protected by intellectual property laws. You may not reproduce this content without our express written permission.',
            ),
            _buildSection(
              '5. Limitation of Liability',
              'We are not liable for any direct or indirect damages arising from your use of Saree Bazaar, including errors in product descriptions or delivery delays caused by third-party logistics.',
            ),
            _buildSection(
              '6. Governing Law',
              'These terms are governed by the laws of India. Any disputes arising from these terms will be resolved in the courts of Kolkata.',
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Last Updated: March 29, 2026',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

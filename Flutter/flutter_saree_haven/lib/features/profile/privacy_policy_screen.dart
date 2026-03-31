import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
              '1. Information We Collect',
              'We collect information you provide directly to us when you create an account, make a purchase, or communicate with us. This includes your name, email, phone number, and shipping address.',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use your information to provide our services, process transactions, communicate with you, and improve your shopping experience. We do not sell your personal data to third parties.',
            ),
            _buildSection(
              '3. Data Protection',
              'We implement state-of-the-art security measures to protect your personal information from unauthorized access, alteration, or disclosure. Your payment data is processed through industry-standard encrypted channels.',
            ),
            _buildSection(
              '4. Your Choices',
              'You can update your profile information at any time through our settings. You can also opt-out of promotional communications through the notification toggles in the settings menu.',
            ),
            _buildSection(
              '5. Cookies',
              'We use cookies and similar tracking technologies to analyze app traffic and personalize your experience. You can manage your preferences through your device settings.',
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

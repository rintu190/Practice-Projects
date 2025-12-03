import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Last updated: 1 January 2024',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: '1. Information We Collect',
                content:
                    'We collect information you provide directly to us, such as when you create an account, complete your profile, or contact us for support. This includes personal information like your name, email address, phone number, and financial information.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '2. How We Use Your Information',
                content:
                    'We use the information we collect to provide and improve our services, process transactions, send you promotional communications, and comply with legal obligations. Your information helps us understand your needs and provide a better user experience.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '3. Data Protection',
                content:
                    'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '4. Sharing Your Information',
                content:
                    'We do not sell or share your personal information with third parties except as necessary to provide our services, comply with legal obligations, or with your explicit consent.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '5. Cookies and Tracking',
                content:
                    'We use cookies and similar tracking technologies to enhance your experience. You can control cookie settings through your browser preferences.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '6. Your Rights',
                content:
                    'You have the right to access, update, or delete your personal information at any time. You can do this by logging into your account or contacting us directly.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '7. Children\'s Privacy',
                content:
                    'Our services are not intended for children under 18 years of age. We do not knowingly collect personal information from children. If we learn that we have collected personal information from a child, we will promptly delete such information.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '8. Changes to Privacy Policy',
                content:
                    'We may update this privacy policy from time to time. We will notify you of any changes by posting the updated policy on this page with a new "Last updated" date.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '9. Contact Us',
                content:
                    'If you have any questions about this Privacy Policy or our privacy practices, please contact us at privacy@mlinvestment.com',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('I Understand'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

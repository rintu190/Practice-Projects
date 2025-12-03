import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
                'Terms & Conditions',
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
                title: '1. Introduction',
                content:
                    'Welcome to MLM Investment App. These Terms & Conditions govern your use of our platform and services. By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '2. User Eligibility',
                content:
                    'You must be at least 18 years old to use this platform. You are responsible for maintaining the confidentiality of your account information and password. You agree to accept responsibility for all activities that occur under your account.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '3. Investment Risks',
                content:
                    'All investments carry risk. Past performance is not indicative of future results. The value of investments may fluctuate. You acknowledge that you understand the risks associated with investing and have sought professional advice if necessary.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '4. User Responsibilities',
                content:
                    'You agree not to use this platform for any illegal purposes or in violation of any laws or regulations. You are responsible for ensuring that your use complies with all applicable laws and regulations.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '5. Limitation of Liability',
                content:
                    'In no event shall MLM Investment App be liable for any indirect, incidental, special, or consequential damages arising from your use of this platform or any services provided.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '6. Changes to Terms',
                content:
                    'We reserve the right to modify these terms at any time. Your continued use of the platform following any changes constitutes your acceptance of the new terms.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                title: '7. Contact Us',
                content:
                    'If you have any questions about these Terms & Conditions, please contact us at support@mlinvestment.com',
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

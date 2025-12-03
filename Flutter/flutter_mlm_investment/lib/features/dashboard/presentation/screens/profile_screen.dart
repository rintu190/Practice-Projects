import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../support/presentation/screens/help_support_screen.dart';
import '../../../support/presentation/screens/terms_conditions_screen.dart';
import '../../../support/presentation/screens/privacy_policy_screen.dart';
import '../../../profile/presentation/screens/bank_details_screen.dart';
import '../../../profile/presentation/screens/personal_details_screen.dart';
import '../../../profile/presentation/screens/kyc_screen.dart';
import '../../data/services/dashboard_service.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = DashboardService().getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header with Real User Data
              Center(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _dashboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingProfile();
                    }

                    if (snapshot.hasError) {
                      return _buildErrorProfile();
                    }

                    final userName = snapshot.data?['user']?['name'] ?? 'User';
                    final userRank = snapshot.data?['user']?['rank'] ?? 'Basic';

                    return Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _dashboardFuture,
                          builder: (context, snapshot) {
                            final referralCode = snapshot.data?['user']?['referral_code'] ?? '';
                            return Text(
                              'ID: $referralCode',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.2,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$userRank Member',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _dashboardFuture,
                          builder: (context, snapshot) {
                            final kycStatus = snapshot.data?['user']?['kyc_status'] ?? 'pending';
                            
                            Color statusColor;
                            String statusText;
                            IconData statusIcon;

                            switch (kycStatus) {
                              case 'approved':
                                statusColor = AppColors.success;
                                statusText = 'KYC Verified';
                                statusIcon = Icons.verified_rounded;
                                break;
                              case 'submitted':
                              case 'pending':
                                statusColor = Colors.orange;
                                statusText = 'KYC Pending';
                                statusIcon = Icons.pending_rounded;
                                break;
                              case 'rejected':
                                statusColor = AppColors.error;
                                statusText = 'KYC Rejected';
                                statusIcon = Icons.error_rounded;
                                break;
                              default:
                                statusColor = Colors.grey;
                                statusText = 'KYC Not Verified';
                                statusIcon = Icons.info_rounded;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon,
                                      size: 14, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Menu Options
              _buildMenuSection(context, 'Account', [
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalDetailsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_rounded,
                  title: 'Bank Details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BankDetailsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.verified_user_outlined,
                  title: 'KYC Status',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KycScreen(),
                      ),
                    );
                  },
                  trailing: const Icon(Icons.check_circle,
                      color: AppColors.success, size: 16),
                ),
              ]),

              _buildMenuSection(context, 'Security', [
                _buildMenuItem(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.pin_drop_outlined,
                  title: 'Transaction PIN',
                  onTap: () {},
                ),
              ]),

              _buildMenuSection(context, 'Support', [
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsConditionsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Logout Logic
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon:
                      const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingProfile() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          width: 150,
          height: 20,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorProfile() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.error, width: 2),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 50,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Error Loading Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

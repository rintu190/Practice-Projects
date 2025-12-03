import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/compliance_config.dart';
import '../../../../features/dashboard/presentation/screens/dashboard_screen.dart';

class RiskDisclosureScreen extends StatefulWidget {
  const RiskDisclosureScreen({super.key});

  @override
  State<RiskDisclosureScreen> createState() => _RiskDisclosureScreenState();
}

class _RiskDisclosureScreenState extends State<RiskDisclosureScreen> {
  bool _acceptedInvestmentRisk = false;
  bool _acceptedMLMRisk = false;
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _isLoading = false;

  bool get _allAccepted =>
      _acceptedInvestmentRisk &&
      _acceptedMLMRisk &&
      _acceptedTerms &&
      _acceptedPrivacy;

  Future<void> _submitDisclosure() async {
    if (!_allAccepted) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call to record consent
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Registration Complete'),
          content: const Text(
            'Your account has been created successfully. Please wait for admin approval of your KYC documents.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to Dashboard (Placeholder for now)
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
      activeColor: AppColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Disclosure'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Disclosures',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please read and accept the following terms and risk warnings to proceed.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSection('Investment Risks', ComplianceConfig.investmentRiskWarning),
                    _buildSection('MLM Business Risks', ComplianceConfig.mlmBusinessRisk),
                    _buildSection('Terms & Conditions', ComplianceConfig.termsAndConditions),
                    _buildSection('Privacy Policy', ComplianceConfig.privacyPolicy),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildCheckbox(
                      ComplianceConfig.consentInvestmentRisk,
                      _acceptedInvestmentRisk,
                      (val) => setState(() => _acceptedInvestmentRisk = val ?? false),
                    ),
                    _buildCheckbox(
                      ComplianceConfig.consentMLMRisk,
                      _acceptedMLMRisk,
                      (val) => setState(() => _acceptedMLMRisk = val ?? false),
                    ),
                    _buildCheckbox(
                      ComplianceConfig.consentTerms,
                      _acceptedTerms,
                      (val) => setState(() => _acceptedTerms = val ?? false),
                    ),
                    _buildCheckbox(
                      ComplianceConfig.consentPrivacy,
                      _acceptedPrivacy,
                      (val) => setState(() => _acceptedPrivacy = val ?? false),
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _allAccepted && !_isLoading ? _submitDisclosure : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('I Accept & Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

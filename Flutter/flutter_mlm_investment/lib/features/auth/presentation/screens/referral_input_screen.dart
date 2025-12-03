import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import 'kyc_upload_screen.dart';

class ReferralInputScreen extends StatefulWidget {
  final String phoneNumber;
  
  const ReferralInputScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<ReferralInputScreen> createState() => _ReferralInputScreenState();
}

class _ReferralInputScreenState extends State<ReferralInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referralController = TextEditingController();
  bool _isLoading = false;
  bool _hasReferral = true; // Toggle for "I don't have a referral code"

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submitReferral() async {
    if (_hasReferral && !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthProvider>().register(
        widget.phoneNumber,
        _hasReferral ? _referralController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_hasReferral 
              ? 'Referral code linked successfully!' 
              : 'Proceeding without referral code'),
          ),
        );
        
        // Navigate to next screen (KYC)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KycUploadScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_outline_rounded,
                      size: 50,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'Who invited you?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the referral code of the person who invited you to join.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Toggle for having referral code
                SwitchListTile(
                  title: const Text('I have a referral code'),
                  value: _hasReferral,
                  onChanged: (value) {
                    setState(() {
                      _hasReferral = value;
                      if (!value) {
                        _referralController.clear();
                      }
                    });
                  },

                  contentPadding: EdgeInsets.zero,
                ),
                
                if (_hasReferral) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _referralController,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Referral Code',
                      hintText: 'e.g. ABC12345',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter referral code';
                      }
                      if (value.length < 6) {
                        return 'Invalid referral code';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                ],

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReferral,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_hasReferral ? 'Validate & Continue' : 'Skip & Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

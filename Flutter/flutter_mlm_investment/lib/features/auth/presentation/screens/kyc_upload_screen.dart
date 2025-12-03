import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/document_upload_widget.dart';
import 'bank_details_screen.dart';

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  File? _panImage;
  File? _aadhaarFrontImage;
  File? _aadhaarBackImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          switch (type) {
            case 'pan':
              _panImage = File(image.path);
              break;
            case 'aadhaar_front':
              _aadhaarFrontImage = File(image.path);
              break;
            case 'aadhaar_back':
              _aadhaarBackImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  Future<void> _submitKyc() async {
    if (_panImage == null || _aadhaarFrontImage == null || _aadhaarBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API upload
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC Documents Uploaded Successfully!')),
      );

      // Navigate to Bank Details Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BankDetailsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Documents',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please upload clear photos of your original documents for verification.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // PAN Card
              DocumentUploadWidget(
                title: 'PAN Card',
                subtitle: 'Upload front side of PAN card',
                imageFile: _panImage,
                onTap: () => _pickImage('pan'),
                onRemove: () => setState(() => _panImage = null),
              ),
              const SizedBox(height: 24),

              // Aadhaar Front
              DocumentUploadWidget(
                title: 'Aadhaar Card (Front)',
                subtitle: 'Upload front side of Aadhaar card',
                imageFile: _aadhaarFrontImage,
                onTap: () => _pickImage('aadhaar_front'),
                onRemove: () => setState(() => _aadhaarFrontImage = null),
              ),
              const SizedBox(height: 24),

              // Aadhaar Back
              DocumentUploadWidget(
                title: 'Aadhaar Card (Back)',
                subtitle: 'Upload back side of Aadhaar card',
                imageFile: _aadhaarBackImage,
                onTap: () => _pickImage('aadhaar_back'),
                onRemove: () => setState(() => _aadhaarBackImage = null),
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitKyc,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Documents'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Center(
                child: TextButton(
                  onPressed: () {
                    // Skip logic if allowed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BankDetailsScreen()),
                    );
                  },
                  child: const Text('Skip for now (Verification Pending)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/kyc_service.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _kycService = KycService();
  final _imagePicker = ImagePicker();
  
  File? _panImage;
  File? _aadhaarFront;
  File? _aadhaarBack;
  
  bool _isLoading = false;
  bool _isUploading = false;
  Map<String, dynamic>? _kycStatus;

  @override
  void initState() {
    super.initState();
    _loadKycStatus();
  }

  @override
  void dispose() {
    _panController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _loadKycStatus() async {
    setState(() => _isLoading = true);
    try {
      final response = await _kycService.getKycStatus();
      setState(() {
        _kycStatus = response['data'];
        if (_kycStatus != null) {
          _panController.text = _kycStatus!['pan_number'] ?? '';
          // Show masked Aadhaar number (backend already masks it as XXXXXX1234)
          _aadhaarController.text = _kycStatus!['aadhaar_number'] ?? '';
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading KYC status: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        switch (type) {
          case 'pan':
            _panImage = File(image.path);
            break;
          case 'aadhaar_front':
            _aadhaarFront = File(image.path);
            break;
          case 'aadhaar_back':
            _aadhaarBack = File(image.path);
            break;
        }
      });
    }
  }

  Future<void> _uploadKyc() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check if documents are provided (either new upload or already existing)
    // Note: The backend 'aadhaar_uploaded' flag implies both front and back are present.
    // If we wanted finer granularity, the backend would need to return separate flags.
    // For now, if aadhaar is uploaded, we assume both are there. 
    // If user picks a new front image but not back, we send the new front. 
    // But we need to ensure we don't block submission if they don't pick a back image 
    // when one is already on server.
    
    // However, if they are re-uploading, they might want to replace just one.
    // The logic below ensures that for a *fresh* submission, everything is there.
    // For a re-submission, we ensure that between what's on server and what's picked, we have everything.
    
    // Refined check:
    final panOk = _panImage != null || (_kycStatus?['pan_uploaded'] == true);
    // We treat aadhaar front/back separately for local checks, but server gives us one flag.
    // If server says uploaded, we assume both are there.
    final aadhaarFrontOk = _aadhaarFront != null || (_kycStatus?['aadhaar_uploaded'] == true);
    final aadhaarBackOk = _aadhaarBack != null || (_kycStatus?['aadhaar_uploaded'] == true);

    if (!panOk || !aadhaarFrontOk || !aadhaarBackOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      await _kycService.uploadKyc(
        panNumber: _panController.text,
        aadhaarNumber: _aadhaarController.text,
        panImage: _panImage,
        aadhaarFront: _aadhaarFront,
        aadhaarBack: _aadhaarBack,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC documents uploaded successfully!')),
        );
        _loadKycStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _kycStatus?['status'] ?? 'pending';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    if (_kycStatus != null) _buildStatusCard(status),
                    const SizedBox(height: 24),

                    // Instructions
                    Text(
                      isApproved ? 'Verified Documents' : 'Upload Documents',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isApproved 
                          ? 'Your KYC documents have been verified'
                          : 'Please upload clear images of your PAN card and Aadhaar card',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PAN Number
                    TextFormField(
                      controller: _panController,
                      decoration: const InputDecoration(
                        labelText: 'PAN Number',
                        hintText: 'ABCDE1234F',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 10,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final pan = v.trim().toUpperCase();
                        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
                          return 'Invalid PAN format';
                        }
                        return null;
                      },
                      enabled: !isApproved,
                    ),
                    const SizedBox(height: 16),

                    // PAN Image Upload
                    _buildImageUploadCard(
                      'PAN Card Image',
                      _panImage,
                      () => !isApproved ? _pickImage('pan') : null,
                      _kycStatus?['pan_uploaded'] == true,
                      isApproved: isApproved,
                    ),
                    const SizedBox(height: 24),

                    // Aadhaar Number
                    TextFormField(
                      controller: _aadhaarController,
                      decoration: const InputDecoration(
                        labelText: 'Aadhaar Number',
                        hintText: '1234 5678 9012',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!RegExp(r'^[0-9]{12}$').hasMatch(v)) {
                          return 'Invalid Aadhaar format';
                        }
                        return null;
                      },
                      enabled: !isApproved,
                    ),
                    const SizedBox(height: 16),

                    // Aadhaar Front Image
                    _buildImageUploadCard(
                      'Aadhaar Front Image',
                      _aadhaarFront,
                      () => !isApproved ? _pickImage('aadhaar_front') : null,
                      _kycStatus?['aadhaar_uploaded'] == true,
                      isApproved: isApproved,
                    ),
                    const SizedBox(height: 16),

                    // Aadhaar Back Image
                    _buildImageUploadCard(
                      'Aadhaar Back Image',
                      _aadhaarBack,
                      () => !isApproved ? _pickImage('aadhaar_back') : null,
                      _kycStatus?['aadhaar_uploaded'] == true,
                      isApproved: isApproved,
                    ),
                    const SizedBox(height: 32),

                    // Upload Button
                    if (!isApproved)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isUploading ? null : _uploadKyc,
                          child: _isUploading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(isRejected ? 'Resubmit for Verification' : 'Submit for Verification'),
                        ),
                      ),

                    // Rejection Reason
                    if (isRejected && _kycStatus?['rejection_reason'] != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rejection Reason:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_kycStatus!['rejection_reason']),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Verified';
        break;
      case 'submitted':
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Under Review';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Not Submitted';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadCard(
    String title,
    File? image,
    VoidCallback? onTap,
    bool isUploaded, {
    bool isApproved = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null || isUploaded
                ? Colors.green
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: image != null || isUploaded
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(image, fit: BoxFit.cover),
                    )
                  : Icon(
                      isUploaded ? Icons.check_circle : Icons.upload_file,
                      color: isUploaded ? Colors.green : Colors.grey,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image != null
                        ? 'Image selected'
                        : isUploaded
                            ? (isApproved ? 'Verified' : 'Already uploaded')
                            : 'Tap to upload',
                    style: TextStyle(
                      fontSize: 12,
                      color: image != null || isUploaded
                          ? Colors.green
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isApproved)
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

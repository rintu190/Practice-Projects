import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/saree_image.dart';
import '../auth/auth_service.dart';

class EditShopProfileScreen extends StatefulWidget {
  const EditShopProfileScreen({super.key});

  @override
  State<EditShopProfileScreen> createState() => _EditShopProfileScreenState();
}

class _EditShopProfileScreenState extends State<EditShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _contactController;
  late TextEditingController _locationController;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _nameController = TextEditingController(text: auth.shopName);
    _aboutController = TextEditingController(text: auth.shopAbout);
    _contactController = TextEditingController(text: auth.shopContact);
    _locationController = TextEditingController(text: auth.shopLocation);
    _existingImageUrl = auth.sellerProfile?.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthService>().updateShopProfile(
              name: _nameController.text,
              about: _aboutController.text,
              contact: _contactController.text,
              location: _locationController.text,
              imageBytes: _selectedImageBytes,
              imageName: _selectedImageName,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shop profile updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Shop Profile Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Saree House Photo'),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedImageBytes != null
                              ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                              : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                                  ? SareeImage(imageUrl: _existingImageUrl!, fit: BoxFit.cover)
                                  : Container(
                                      color: AppColors.primary.withValues(alpha: 0.05),
                                      child: const Icon(Icons.storefront_outlined, size: 48, color: AppColors.primary),
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Saree House Name',
                hint: 'e.g. Saree Haven Elite',
                icon: Icons.storefront_outlined,
                validator: (v) => v!.isEmpty ? 'Please enter shop name' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _aboutController,
                label: 'About Shop',
                hint: 'Tell customers about your collection...',
                icon: Icons.info_outline,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Please enter shop description' : null,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Contact & Location'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contactController,
                label: 'Contact Number',
                hint: 'e.g. +91 98765 43210',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Please enter contact number' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _locationController,
                label: 'Shop Location',
                hint: 'e.g. Surat, Gujarat, India',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Icon(icon, color: AppColors.primary.withValues(alpha: 0.6), size: 20),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          ),
        ),
      ],
    );
  }
}

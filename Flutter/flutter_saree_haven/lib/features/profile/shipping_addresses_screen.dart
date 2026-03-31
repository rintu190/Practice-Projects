import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/data/api_repository.dart';
import '../../core/models/address_model.dart';
import '../auth/auth_service.dart';

class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});

  @override
  State<ShippingAddressesScreen> createState() => _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  late Future<List<ShippingAddress>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final userId = context.read<AuthService>().userId ?? '';
    _addressesFuture = ApiRepository.getAddresses(userId);
  }

  Future<void> _deleteAddress(int id) async {
    final userId = context.read<AuthService>().userId ?? '';
    try {
      await ApiRepository.deleteAddress(id, userId);
      setState(() => _refresh());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  void _showAddressDialog([ShippingAddress? address]) {
    final isEditing = address != null;
    final labelController = TextEditingController(text: address?.label);
    final detailsController = TextEditingController(text: address?.details);
    bool isDefault = address?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Address' : 'Add New Address', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Label (e.g. Home, Office)'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'Details'),
                  maxLines: 3,
                ),
                CheckboxListTile(
                  title: const Text('Set as Default'),
                  value: isDefault,
                  onChanged: (v) => setDialogState(() => isDefault = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final userId = context.read<AuthService>().userId ?? '';
                if (isEditing) {
                  await ApiRepository.updateAddress(
                      address.id, userId, labelController.text, detailsController.text, isDefault);
                } else {
                  await ApiRepository.addAddress(
                      userId, labelController.text, detailsController.text, isDefault);
                }
                if (mounted) {
                  Navigator.pop(context);
                  setState(() => _refresh());
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Shipping Addresses',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<List<ShippingAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final addresses = snapshot.data ?? [];
          if (addresses.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(child: Text('No addresses found')),
                const SizedBox(height: 16),
                _buildAddButton(),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: addresses.length + 1,
            itemBuilder: (context, index) {
              if (index == addresses.length) {
                return _buildAddButton();
              }
              final address = addresses[index];
              return _buildAddressCard(address);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DottedBorderButton(
        onTap: () => _showAddressDialog(),
        text: 'Add New Address',
        icon: Icons.add_location_alt_outlined,
      ),
    );
  }

  Widget _buildAddressCard(ShippingAddress address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(address.label == 'Home' ? Icons.home_outlined : Icons.work_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(address.label,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('Default',
                      style: GoogleFonts.poppins(
                          color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                )
            ],
          ),
          const SizedBox(height: 12),
          Text(address.details,
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => _showAddressDialog(address),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('Edit',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () => _deleteAddress(address.id),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('Delete',
                    style:
                        GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.redAccent)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DottedBorderButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;

  const DottedBorderButton({super.key, required this.onTap, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5), width: 1.5, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(text,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/data/api_repository.dart';
import '../../core/models/payment_model.dart';
import '../auth/auth_service.dart';
import 'shipping_addresses_screen.dart'; // To reuse DottedBorderButton

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late Future<List<PaymentMethod>> _methodsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final userId = context.read<AuthService>().userId ?? '';
    _methodsFuture = ApiRepository.getPaymentMethods(userId);
  }

  Future<void> _deleteMethod(int id) async {
    final userId = context.read<AuthService>().userId ?? '';
    try {
      await ApiRepository.deletePaymentMethod(id, userId);
      setState(() => _refresh());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  void _showPaymentDialog([PaymentMethod? method]) {
    final isEditing = method != null;
    final typeController = TextEditingController(text: method?.type ?? 'Visa');
    final lastFourController = TextEditingController(text: method?.lastFour);
    final expiryController = TextEditingController(text: method?.expiry);
    final holderController = TextEditingController(text: method?.cardHolder);
    bool isDefault = method?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Payment Method' : 'Add New Payment Method',
              style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: typeController.text,
                  items: ['Visa', 'MasterCard', 'UPI', 'RuPay']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => typeController.text = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                TextField(
                  controller: holderController,
                  decoration: const InputDecoration(labelText: 'Card Holder Name'),
                ),
                TextField(
                  controller: lastFourController,
                  decoration: const InputDecoration(labelText: 'Last 4 Digits'),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
                TextField(
                  controller: expiryController,
                  decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
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
                  await ApiRepository.updatePaymentMethod(
                    method.id,
                    userId,
                    typeController.text,
                    lastFourController.text,
                    expiryController.text,
                    holderController.text,
                    isDefault,
                  );
                } else {
                  await ApiRepository.addPaymentMethod(
                    userId,
                    typeController.text,
                    lastFourController.text,
                    expiryController.text,
                    holderController.text,
                    isDefault,
                  );
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
        title: Text('Payment Methods',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<List<PaymentMethod>>(
        future: _methodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final methods = snapshot.data ?? [];
          if (methods.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(child: Text('No payment methods found')),
                const SizedBox(height: 16),
                _buildAddButton(),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: methods.length + 1,
            itemBuilder: (context, index) {
              if (index == methods.length) {
                return _buildAddButton();
              }
              final method = methods[index];
              return _buildPaymentCard(method);
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
        onTap: () => _showPaymentDialog(),
        text: 'Add New Payment Method',
        icon: Icons.add_card,
      ),
    );
  }

  Widget _buildPaymentCard(PaymentMethod method) {
    final bool isVisa = method.type == 'Visa';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isVisa ? const LinearGradient(colors: [Color(0xFF2B32B2), Color(0xFF1488CC)]) : null,
        color: !isVisa ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                method.type,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isVisa ? Colors.white : AppColors.textPrimary),
              ),
              if (method.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: isVisa ? Colors.white.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('Default',
                      style: GoogleFonts.poppins(
                          color: isVisa ? Colors.white : AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                )
            ],
          ),
          const SizedBox(height: 12),
          Text(method.cardHolder,
              style: GoogleFonts.poppins(
                  color: isVisa ? Colors.white70 : AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Text(
            '**** **** **** ${method.lastFour}',
            style: GoogleFonts.robotoMono(
                fontSize: 18,
                letterSpacing: 2,
                color: isVisa ? Colors.white : AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (method.expiry.isNotEmpty)
                Text('Exp: ${method.expiry}',
                    style: GoogleFonts.poppins(
                        color: isVisa ? Colors.white70 : AppColors.textSecondary, fontSize: 12)),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showPaymentDialog(method),
                    icon: Icon(Icons.edit, color: isVisa ? Colors.white : AppColors.primary, size: 20),
                  ),
                  IconButton(
                    onPressed: () => _deleteMethod(method.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

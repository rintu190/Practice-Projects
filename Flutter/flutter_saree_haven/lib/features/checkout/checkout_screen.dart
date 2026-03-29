import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../cart/cart_service.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinController = TextEditingController();
  String _paymentMethod = 'COD';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Shipping Address', Icons.local_shipping_outlined),
              const SizedBox(height: 16),
              _card([
                _field(_nameController, 'Full Name', Icons.person_outline),
                const SizedBox(height: 12),
                _field(_phoneController, 'Phone Number', Icons.phone_outlined, type: TextInputType.phone),
                const SizedBox(height: 12),
                _field(_addressController, 'Street Address', Icons.home_outlined, lines: 2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field(_cityController, 'City', Icons.location_city_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_pinController, 'PIN Code', Icons.pin_drop_outlined, type: TextInputType.number)),
                  ],
                ),
              ]),
              const SizedBox(height: 28),
              _sectionTitle('Payment Method', Icons.payment_outlined),
              const SizedBox(height: 16),
              _card([
                _payOption('COD', 'Cash on Delivery', Icons.money),
                const Divider(height: 1),
                _payOption('UPI', 'UPI Payment', Icons.account_balance),
                const Divider(height: 1),
                _payOption('Card', 'Credit/Debit Card', Icons.credit_card),
              ]),
              const SizedBox(height: 28),
              _sectionTitle('Order Summary', Icons.receipt_outlined),
              const SizedBox(height: 16),
              _buildOrderSummary(cart),
              const SizedBox(height: 32),
              _buildPlaceOrderButton(cart),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {int lines = 1, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      keyboardType: type,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _payOption(String value, String label, IconData icon) {
    final sel = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: sel ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: sel ? AppColors.primary : AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? AppColors.textPrimary : AppColors.textSecondary))),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300, width: 2), color: sel ? AppColors.primary : Colors.transparent),
              child: sel ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartService cart) {
    return _card([
      ...cart.items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(child: Text('${item.saree.name} × ${item.quantity}', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary))),
            Text('₹${item.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      )),
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Delivery', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
          Text('FREE', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2ECC71))),
        ],
      ),
      const SizedBox(height: 12),
      const Divider(),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('₹${cart.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    ]);
  }

  Widget _buildPlaceOrderButton(CartService cart) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final total = cart.totalPrice;
            final count = cart.itemCount;
            cart.clearCart();
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (_) => OrderConfirmationScreen(totalAmount: total, itemCount: count),
            ));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Place Order  •  ₹${cart.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/investment_product.dart';
import '../../data/services/investment_service.dart';
import 'package:provider/provider.dart';
import '../../../dashboard/data/providers/dashboard_provider.dart';

class BuyInvestmentScreen extends StatefulWidget {
  const BuyInvestmentScreen({super.key});

  @override
  State<BuyInvestmentScreen> createState() => _BuyInvestmentScreenState();
}

class _BuyInvestmentScreenState extends State<BuyInvestmentScreen> {
  final _investmentService = InvestmentService();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isInvesting = false;
  List<InvestmentProduct> _products = [];
  InvestmentProduct? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _investmentService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  Future<void> _invest() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) return;

    final amount = double.parse(_amountController.text);
    final walletBalance = double.tryParse((context
                    .read<DashboardProvider>()
                    .walletData?['e_wallet']?['balance'] ??
                0)
            .toString()) ??
        0.0;

    if (amount > walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient wallet balance')),
      );
      return;
    }

    setState(() => _isInvesting = true);

    try {
      await _investmentService.invest(_selectedProduct!.id, amount);

      if (mounted) {
        // Refresh dashboard data
        context.read<DashboardProvider>().refreshAll();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title:
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Investment Successful!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Your investment has been activated.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isInvesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Investment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Plan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (_products.isEmpty)
                      const Center(child: Text('No investment plans available'))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _products.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final isSelected = _selectedProduct?.id == product.id;

                          return _buildProductCard(product, isSelected);
                        },
                      ),
                    const SizedBox(height: 32),
                    if (_selectedProduct != null) ...[
                      Text(
                        'Investment Amount',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.currency_rupee),
                          labelText: 'Amount',
                          hintText:
                              'Min: ${Formatters.formatCurrency(_selectedProduct!.minAmount)}',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final amount = double.tryParse(value);
                          if (amount == null) return 'Invalid amount';

                          final min = _selectedProduct!.minAmount;
                          final max =
                              _selectedProduct!.maxAmount ?? double.infinity;

                          if (amount < min)
                            return 'Minimum amount is ${Formatters.formatCurrency(min)}';
                          if (amount > max)
                            return 'Maximum amount is ${Formatters.formatCurrency(max)}';

                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isInvesting ? null : _invest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isInvesting
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Invest Now',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductCard(InvestmentProduct product, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProduct = product;
          _amountController.text = product.minAmount.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoBadge(
                  'ROI: ${product.roiPercentage}%',
                  Colors.green,
                ),
                _buildInfoBadge(
                  '${product.durationDays} Days',
                  Colors.blue,
                ),
                _buildInfoBadge(
                  'Min: ${Formatters.formatCurrency(product.minAmount)}',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

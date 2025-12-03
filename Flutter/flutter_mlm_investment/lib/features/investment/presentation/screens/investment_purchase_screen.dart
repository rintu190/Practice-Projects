import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/investment_service.dart';
import '../../../dashboard/data/services/dashboard_service.dart';
import '../screens/investment_categories_screen.dart'; // For InvestmentPlan model

class InvestmentPurchaseScreen extends StatefulWidget {
  final InvestmentCategory category;
  final InvestmentPlan plan;

  const InvestmentPurchaseScreen({
    super.key,
    required this.category,
    required this.plan,
  });

  @override
  State<InvestmentPurchaseScreen> createState() =>
      _InvestmentPurchaseScreenState();
}

class _InvestmentPurchaseScreenState extends State<InvestmentPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _investmentService = InvestmentService();
  final _dashboardService = DashboardService();
  
  bool _isLoading = false;
  bool _autoRenew = false;
  double _walletBalance = 0.0;
  bool _loadingBalance = true;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.plan.minAmount.toStringAsFixed(0);
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final data = await _dashboardService.getDashboardData();
      if (mounted) {
        setState(() {
          // Check both wallet structures just in case
          final walletData = data['wallet'];
          if (walletData != null) {
            _walletBalance = double.tryParse(
                    (walletData['balance'] ?? walletData['e_wallet_balance'] ?? 0)
                        .toString()) ??
                0.0;
          }
          _loadingBalance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingBalance = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wallet balance: $e')),
        );
      }
    }
  }

  Future<void> _handlePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    if (amount > _walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient wallet balance')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _investmentService.invest(
        widget.plan.id,
        amount,
        autoRenew: _autoRenew,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Investment successful!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Pop back to portfolio (pop categories screen too)
        Navigator.of(context).pop(); // Pop purchase screen
        Navigator.of(context).pop(); // Pop categories screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Investment failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Investment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.category.color),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(widget.category.icon,
                            color: widget.category.color, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.category.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.plan.tier} Plan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.category.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem('ROI', '${widget.plan.roiPercentage}%'),
                        _buildSummaryItem('Duration', '${widget.plan.duration} Days'),
                        _buildSummaryItem(
                            'Min Amount',
                            Formatters.formatCurrency(
                                widget.plan.minAmount.toDouble())),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Wallet Balance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Wallet Balance',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _loadingBalance
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            Formatters.formatCurrency(_walletBalance),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount Input
              const Text(
                'Investment Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Invalid amount';
                  }
                  if (amount < widget.plan.minAmount) {
                    return 'Minimum investment is ${Formatters.formatCurrency(widget.plan.minAmount)}';
                  }
                  if (widget.plan.maxAmount != null &&
                      amount > widget.plan.maxAmount!) {
                    return 'Maximum investment is ${Formatters.formatCurrency(widget.plan.maxAmount!)}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Auto Renew Toggle
              SwitchListTile(
                value: _autoRenew,
                onChanged: (value) => setState(() => _autoRenew = value),
                title: const Text('Auto-Renew Investment'),
                subtitle: const Text(
                    'Automatically reinvest principal and profit at maturity'),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 32),

              // Purchase Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Investment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

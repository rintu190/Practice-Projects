import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/investment_product.dart';
import '../../data/services/investment_service.dart';
import 'package:provider/provider.dart';
import '../../../dashboard/data/providers/dashboard_provider.dart';

class InvestmentProductsScreen extends StatefulWidget {
  const InvestmentProductsScreen({super.key});

  @override
  State<InvestmentProductsScreen> createState() =>
      _InvestmentProductsScreenState();
}

class _InvestmentProductsScreenState extends State<InvestmentProductsScreen> {
  final _investmentService = InvestmentService();
  bool _isLoading = true;
  List<InvestmentProduct> _products = [];

  // Filters
  String? _selectedType;
  String? _selectedRisk;
  String? _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _investmentService.getProducts(
        type: _selectedType,
        risk: _selectedRisk,
        frequency: _selectedFrequency,
      );
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showInvestModal(InvestmentProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvestModal(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Plans'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Text('No plans found matching filters'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _products.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            _buildProductCard(_products[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Type', _selectedType,
              ['fixed_plan', 'fund', 'instrument', 'profit_sharing'], (val) {
            setState(() => _selectedType = val);
            _loadProducts();
          }),
          const SizedBox(width: 8),
          _buildFilterChip('Risk', _selectedRisk, ['low', 'medium', 'high'],
              (val) {
            setState(() => _selectedRisk = val);
            _loadProducts();
          }),
          const SizedBox(width: 8),
          _buildFilterChip('Frequency', _selectedFrequency,
              ['daily', 'weekly', 'monthly', 'maturity'], (val) {
            setState(() => _selectedFrequency = val);
            _loadProducts();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? selectedValue,
      List<String> options, Function(String?) onChanged) {
    return FilterChip(
      label: Text(selectedValue == null
          ? label
          : selectedValue.toUpperCase().replaceAll('_', ' ')),
      selected: selectedValue != null,
      onSelected: (bool selected) {
        if (selected) {
          _showFilterOptions(label, options, onChanged);
        } else {
          onChanged(null);
        }
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color:
            selectedValue != null ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selectedValue != null ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showFilterOptions(
      String title, List<String> options, Function(String?) onChanged) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              title: Text('Select $title',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          ...options.map((opt) => ListTile(
                title: Text(opt.toUpperCase().replaceAll('_', ' ')),
                onTap: () {
                  onChanged(opt);
                  Navigator.pop(context);
                },
              )),
          ListTile(
            title:
                const Text('Clear Filter', style: TextStyle(color: Colors.red)),
            onTap: () {
              onChanged(null);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(InvestmentProduct product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showInvestModal(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildRiskBadge(product.riskLevel),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('ROI', '${product.roiPercentage}%',
                      product.roiFrequency.toUpperCase()),
                  _buildStat('Duration', '${product.durationDays}', 'DAYS'),
                  _buildStat('Min Invest',
                      Formatters.formatCurrency(product.minAmount), ''),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showInvestModal(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Invest Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color;
    switch (risk) {
      case 'low':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'high':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        risk.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStat(String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (sub.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(sub,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ],
        ),
      ],
    );
  }
}

class _InvestModal extends StatefulWidget {
  final InvestmentProduct product;

  const _InvestModal({required this.product});

  @override
  State<_InvestModal> createState() => _InvestModalState();
}

class _InvestModalState extends State<_InvestModal> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _investmentService = InvestmentService();
  bool _autoRenew = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.product.minAmount.toStringAsFixed(0);
  }

  Future<void> _invest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await _investmentService.invest(
        widget.product.id,
        double.parse(_amountController.text),
        autoRenew: _autoRenew,
      );

      if (mounted) {
        context.read<DashboardProvider>().refreshAll();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Investment successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invest in ${widget.product.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: const Icon(Icons.currency_rupee),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                helperText:
                    'Min: ${Formatters.formatCurrency(widget.product.minAmount)}',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final amount = double.tryParse(value);
                if (amount == null) return 'Invalid amount';
                if (amount < widget.product.minAmount)
                  return 'Min amount is ${widget.product.minAmount}';
                if (widget.product.maxAmount != null &&
                    amount > widget.product.maxAmount!) {
                  return 'Max amount is ${widget.product.maxAmount}';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.product.autoRenewEnabled)
              SwitchListTile(
                title: const Text('Auto-renew at maturity'),
                subtitle:
                    const Text('Reinvest principal + profit automatically'),
                value: _autoRenew,
                onChanged: (val) => setState(() => _autoRenew = val),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _invest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Investment',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

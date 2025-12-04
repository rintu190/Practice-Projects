import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/admin_service.dart';
import '../../../investment/data/models/investment_product.dart';
import '../../../investment/data/services/investment_service.dart';

class InvestmentProductsScreen extends StatefulWidget {
  const InvestmentProductsScreen({super.key});

  @override
  State<InvestmentProductsScreen> createState() => _InvestmentProductsScreenState();
}

class _InvestmentProductsScreenState extends State<InvestmentProductsScreen> {
  final AdminService _adminService = AdminService();
  final InvestmentService _investmentService = InvestmentService();
  List<InvestmentProduct> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
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
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Plans'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_products[index]);
              },
            ),
    );
  }

  Widget _buildProductCard(InvestmentProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.roiPercentage}% ${product.roiFrequency}'),
            Text('Duration: ${product.durationDays} days'),
            Text('Min: ${Formatters.formatCurrency(product.minAmount)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showProductDialog(product: product),
        ),
      ),
    );
  }

  void _showProductDialog({InvestmentProduct? product}) {
    final isEditing = product != null;
    final formKey = GlobalKey<FormState>();
    
    String name = product?.name ?? '';
    String category = product?.category ?? 'Standard';
    String tier = product?.tier ?? 'Bronze';
    String description = product?.description ?? '';
    double minAmount = product?.minAmount ?? 0;
    double? maxAmount = product?.maxAmount;
    double roiPercentage = product?.roiPercentage ?? 0;
    int durationDays = product?.durationDays ?? 30;
    String roiFrequency = product?.roiFrequency ?? 'monthly';
    String riskLevel = product?.riskLevel ?? 'medium';
    String status = product?.status ?? 'active';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Plan' : 'New Plan'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => name = v!,
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (v) => description = v ?? '',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: minAmount.toString(),
                          decoration: const InputDecoration(labelText: 'Min Amount'),
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v!) == null ? 'Invalid' : null,
                          onSaved: (v) => minAmount = double.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: maxAmount?.toString() ?? '',
                          decoration: const InputDecoration(labelText: 'Max Amount'),
                          keyboardType: TextInputType.number,
                          onSaved: (v) => maxAmount = v!.isEmpty ? null : double.tryParse(v),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: roiPercentage.toString(),
                          decoration: const InputDecoration(labelText: 'ROI %'),
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v!) == null ? 'Invalid' : null,
                          onSaved: (v) => roiPercentage = double.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: durationDays.toString(),
                          decoration: const InputDecoration(labelText: 'Duration (Days)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v!) == null ? 'Invalid' : null,
                          onSaved: (v) => durationDays = int.parse(v!),
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: roiFrequency,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: ['daily', 'weekly', 'monthly', 'yearly', 'maturity']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => roiFrequency = v!),
                  ),
                  DropdownButtonFormField<String>(
                    value: riskLevel,
                    decoration: const InputDecoration(labelText: 'Risk Level'),
                    items: ['low', 'medium', 'high']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => riskLevel = v!),
                  ),
                  if (isEditing)
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: ['active', 'inactive']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                          .toList(),
                      onChanged: (v) => setState(() => status = v!),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  try {
                    final data = {
                      'name': name,
                      'category': category,
                      'tier': tier,
                      'description': description,
                      'min_amount': minAmount,
                      'max_amount': maxAmount,
                      'roi_percentage': roiPercentage,
                      'duration_days': durationDays,
                      'roi_frequency': roiFrequency,
                      'risk_level': riskLevel,
                      'status': status,
                    };

                    if (isEditing) {
                      await _adminService.updateProduct(product.id, data);
                    } else {
                      await _adminService.createProduct(data);
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      _loadProducts();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

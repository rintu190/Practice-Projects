import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../admin/data/services/admin_service.dart';
import '../../../investment/data/models/investment_product.dart';

class InvestmentProductDialog extends StatefulWidget {
  final InvestmentProduct? product;
  final VoidCallback onUpdate;

  const InvestmentProductDialog({
    super.key,
    this.product,
    required this.onUpdate,
  });

  @override
  State<InvestmentProductDialog> createState() =>
      _InvestmentProductDialogState();
}

class _InvestmentProductDialogState extends State<InvestmentProductDialog> {
  final AdminService _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;
  late TextEditingController _roiController;
  late TextEditingController _durationController;

  String _category = 'Standard';
  String _tier = 'Bronze';
  String _roiFrequency = 'monthly';
  String _riskLevel = 'medium';
  String _status = 'active';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _minAmountController = TextEditingController(
      text: product?.minAmount.toString() ?? '',
    );
    _maxAmountController = TextEditingController(
      text: product?.maxAmount?.toString() ?? '',
    );
    _roiController = TextEditingController(
      text: product?.roiPercentage.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: product?.durationDays.toString() ?? '',
    );

    if (product != null) {
      _category = product.category ?? 'Standard';
      _tier = product.tier ?? 'Bronze';
      _roiFrequency = product.roiFrequency;
      _riskLevel = product.riskLevel;
      _status = product.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _roiController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'min_amount': double.parse(_minAmountController.text),
        'max_amount': _maxAmountController.text.isEmpty
            ? null
            : double.parse(_maxAmountController.text),
        'roi_percentage': double.parse(_roiController.text),
        'duration_days': int.parse(_durationController.text),
        'category': _category,
        'tier': _tier,
        'roi_frequency': _roiFrequency,
        'risk_level': _riskLevel,
        'status': _status,
      };

      if (widget.product == null) {
        await _adminService.createProduct(data);
      } else {
        await _adminService.updateProduct(widget.product!.id, data);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Plan created successfully'
                : 'Plan updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.inventory_2,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    isEditing
                        ? 'Edit Investment Plan'
                        : 'Create Investment Plan',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Plan Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Min and Max Amount
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minAmountController,
                              decoration: const InputDecoration(
                                labelText: 'Min Amount *',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (v) =>
                                  v!.isEmpty || double.tryParse(v) == null
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _maxAmountController,
                              decoration: const InputDecoration(
                                labelText: 'Max Amount',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ROI and Duration
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _roiController,
                              decoration: const InputDecoration(
                                labelText: 'ROI % *',
                                suffixText: '%',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (v) =>
                                  v!.isEmpty || double.tryParse(v) == null
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration (Days) *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (v) =>
                                  v!.isEmpty || int.tryParse(v) == null
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ROI Frequency and Risk Level
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _roiFrequency,
                              decoration: const InputDecoration(
                                labelText: 'ROI Frequency',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                'daily',
                                'weekly',
                                'monthly',
                                'yearly',
                                'maturity'
                              ]
                                  .map((f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f.toUpperCase()),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _roiFrequency = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _riskLevel,
                              decoration: const InputDecoration(
                                labelText: 'Risk Level',
                                border: OutlineInputBorder(),
                              ),
                              items: ['low', 'medium', 'high']
                                  .map((r) => DropdownMenuItem(
                                        value: r,
                                        child: Text(r.toUpperCase()),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _riskLevel = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status (only for editing)
                      if (isEditing)
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: ['active', 'inactive']
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditing ? 'Update Plan' : 'Create Plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

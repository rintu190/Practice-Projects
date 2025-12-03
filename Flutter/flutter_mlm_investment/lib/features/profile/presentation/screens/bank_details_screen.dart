import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/bank_service.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankService = BankService();

  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _upiController = TextEditingController();

  String _accountType = 'savings';
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isEditing = false;
  Map<String, dynamic>? _bankData;

  @override
  void initState() {
    super.initState();
    _loadBankDetails();
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _loadBankDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await _bankService.getBankDetails();
      final data = response['data']?['data'];

      if (data != null) {
        setState(() {
          _bankData = data;
          _accountHolderController.text =
              (data['account_holder_name'] ?? '').toString();
          _accountNumberController.text =
              (data['account_number'] ?? '').toString();
          _ifscController.text = (data['ifsc_code'] ?? '').toString();
          _bankNameController.text = (data['bank_name'] ?? '').toString();
          _branchController.text = (data['branch_name'] ?? '').toString();
          _upiController.text = (data['upi_id'] ?? '').toString();
          _accountType = (data['account_type'] ?? 'savings').toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBankDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final accountHolder = _accountHolderController.text.trim();
      final accountNumber = _accountNumberController.text.trim();
      final ifscCode = _ifscController.text.trim().toUpperCase();
      final bankName = _bankNameController.text.trim();
      final branchName = _branchController.text.trim().isEmpty
          ? null
          : _branchController.text.trim();
      final upiId = _upiController.text.trim().isEmpty
          ? null
          : _upiController.text.trim();

      if (_bankData == null) {
        // Add new
        await _bankService.addBankDetails(
          accountHolderName: accountHolder,
          accountNumber: accountNumber,
          ifscCode: ifscCode,
          bankName: bankName,
          branchName: branchName,
          accountType: _accountType,
          upiId: upiId,
        );
      } else {
        // Update existing
        await _bankService.updateBankDetails(
          accountHolderName: accountHolder,
          accountNumber: accountNumber,
          ifscCode: ifscCode,
          bankName: bankName,
          branchName: branchName,
          accountType: _accountType,
          upiId: upiId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank details saved successfully!')),
        );
        setState(() => _isEditing = false);
        _loadBankDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = _bankData?['is_verified'] == true ||
        _bankData?['is_verified'] == 1 ||
        _bankData?['is_verified'] == '1';
    final hasData = _bankData != null;
    final canEdit = !isVerified && (hasData ? _isEditing : true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (hasData && !isVerified && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
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
                    // Verification Status
                    if (hasData) _buildStatusCard(isVerified),
                    const SizedBox(height: 24),

                    // Bank Account Details
                    Text(
                      'Bank Account Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _accountHolderController,
                      decoration: const InputDecoration(
                        labelText: 'Account Holder Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      enabled: canEdit,
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Account Number',
                        prefixIcon: Icon(Icons.account_balance),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: canEdit,
                      validator: (v) {
                        final trimmed = v?.trim() ?? '';
                        if (trimmed.isEmpty) return 'Required';
                        if (trimmed.length < 9 || trimmed.length > 18)
                          return 'Invalid account number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _ifscController,
                      decoration: const InputDecoration(
                        labelText: 'IFSC Code',
                        hintText: 'ABCD0123456',
                        prefixIcon: Icon(Icons.code),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 11,
                      enabled: canEdit,
                      validator: (v) {
                        final trimmed = v?.trim() ?? '';
                        if (trimmed.isEmpty) return 'Required';
                        if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
                            .hasMatch(trimmed)) {
                          return 'Invalid IFSC format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bank Name',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      enabled: canEdit,
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _branchController,
                      decoration: const InputDecoration(
                        labelText: 'Branch Name (Optional)',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      enabled: canEdit,
                    ),
                    const SizedBox(height: 16),

                    // Account Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _accountType,
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'savings', child: Text('Savings')),
                        DropdownMenuItem(
                            value: 'current', child: Text('Current')),
                      ],
                      onChanged: canEdit
                          ? (v) => setState(() => _accountType = v!)
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // UPI Details
                    Text(
                      'UPI Details (Optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _upiController,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID',
                        hintText: 'yourname@upi',
                        prefixIcon: Icon(Icons.payment),
                        border: OutlineInputBorder(),
                      ),
                      enabled: canEdit,
                      validator: (v) {
                        final trimmed = v?.trim() ?? '';
                        if (trimmed.isNotEmpty) {
                          if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(trimmed)) {
                            return 'Invalid UPI ID format';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    if (canEdit)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveBankDetails,
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  hasData ? 'Update Details' : 'Save Details'),
                        ),
                      ),

                    // Cancel Edit Button
                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _isEditing = false);
                            _loadBankDetails();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],

                    // Verified Notice
                    if (isVerified) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Your bank details are verified. Contact support to make changes.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
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

  Widget _buildStatusCard(bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isVerified
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            color: isVerified ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  isVerified ? 'Verified' : 'Pending Verification',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

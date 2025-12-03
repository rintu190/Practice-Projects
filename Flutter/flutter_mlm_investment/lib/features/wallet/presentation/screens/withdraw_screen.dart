import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/wallet_service.dart';
import '../../../dashboard/data/providers/dashboard_provider.dart';
import 'add_bank_account_screen.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _walletService = WalletService();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isProcessing = false;
  bool _isLoadingBanks = true;
  List<dynamic> _bankAccounts = [];
  int? _selectedBankId;

  double _withdrawalCharge = 0.0;
  double _netAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
    _amountController.addListener(_calculateCharges);
  }

  @override
  void dispose() {
    _amountController.removeListener(_calculateCharges);
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBankAccounts() async {
    try {
      final accounts = await _walletService.getBankAccounts();
      setState(() {
        _bankAccounts = accounts;
        _isLoadingBanks = false;
        if (accounts.isNotEmpty) {
          _selectedBankId = accounts[0]['id'];
        }
      });
    } catch (e) {
      setState(() => _isLoadingBanks = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bank accounts: $e')),
        );
      }
    }
  }

  void _calculateCharges() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _withdrawalCharge = (amount * 2.0) / 100; // 2% charge
      _netAmount = amount - _withdrawalCharge;
    });
  }

  Future<void> _requestWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank account')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);

      final result = await _walletService.requestWithdrawal(
        walletType: 'e_wallet',
        amount: amount,
        bankAccountId: _selectedBankId!,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title:
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Withdrawal Request Submitted',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  result['message'] ?? 'Your request is under review.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Amount',
                          Formatters.formatCurrency(result['amount'])),
                      _buildInfoRow('Charges',
                          Formatters.formatCurrency(result['charges'])),
                      const Divider(),
                      _buildInfoRow('Net Amount',
                          Formatters.formatCurrency(result['net_amount']),
                          bold: true),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                  context.read<DashboardProvider>().refreshAll();
                },
                child: const Text('OK'),
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
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingBanks
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Selection Removed - Always E-Wallet
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Withdrawing from E-Wallet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Available Balance
                    Consumer<DashboardProvider>(
                      builder: (context, provider, child) {
                        final balance = double.tryParse((provider.walletData?['balance'] ?? 0).toString()) ?? 0.0;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Available Balance'),
                              Text(
                                Formatters.formatCurrency(balance),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Amount Input
                    Text(
                      'Withdrawal Amount',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.currency_rupee),
                        labelText: 'Amount',
                        hintText: 'Min: ₹100',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final amount = double.tryParse(value);
                        if (amount == null) return 'Invalid amount';
                        if (amount < 100) return 'Minimum withdrawal is ₹100';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Charges Breakdown
                    if (_amountController.text.isNotEmpty &&
                        double.tryParse(_amountController.text) != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                                'Withdrawal Amount',
                                Formatters.formatCurrency(
                                    double.parse(_amountController.text))),
                            _buildInfoRow('Processing Charges (2%)',
                                Formatters.formatCurrency(_withdrawalCharge)),
                            const Divider(),
                            _buildInfoRow('You will receive',
                                Formatters.formatCurrency(_netAmount),
                                bold: true),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Bank Account Selection
                    Text(
                      'Bank Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    if (_bankAccounts.isEmpty)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.account_balance,
                                    color: AppColors.primary, size: 48),
                                const SizedBox(height: 12),
                                const Text(
                                  'No bank accounts found',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add a bank account to withdraw funds',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddBankAccountScreen()),
                                    );
                                    if (result == true) {
                                      _loadBankAccounts();
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Bank Account'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedBankId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                        items: _bankAccounts.map((account) {
                          return DropdownMenuItem<int>(
                            value: account['id'],
                            child: Text(
                                '${account['bank_name']} - XXXX${account['account_number'].toString().substring(account['account_number'].toString().length - 4)}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedBankId = value);
                        },
                      ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isProcessing || _bankAccounts.isEmpty)
                            ? null
                            : _requestWithdrawal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Request Withdrawal',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

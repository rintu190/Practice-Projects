import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/wallet_service.dart';
import '../widgets/transfer_dialog.dart';

class TransferScreen extends StatefulWidget {
  final double eWalletBalance;
  final double investmentWalletBalance;

  const TransferScreen({
    super.key,
    required this.eWalletBalance,
    required this.investmentWalletBalance,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Funds'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Overview
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'E-Wallet',
                      Formatters.formatCurrency(widget.eWalletBalance),
                      AppColors.eWallet,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceCard(
                      'Investment',
                      Formatters.formatCurrency(widget.investmentWalletBalance),
                      AppColors.investmentWallet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Transfer Options
              Text(
                'Select Transfer Type',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Option 1: E-Wallet to Investment
              _buildTransferOption(
                'E-Wallet → Investment Wallet',
                'Move funds from E-Wallet to Investment Wallet',
                Icons.trending_up_rounded,
                AppColors.success,
                onTap: () => _showTransferDialog(
                  'E-Wallet to Investment',
                  'e_to_investment',
                  widget.eWalletBalance,
                ),
              ),
              const SizedBox(height: 16),

              // Option 2: Investment to E-Wallet
              _buildTransferOption(
                'Investment Wallet → E-Wallet',
                'Move funds from Investment Wallet to E-Wallet',
                Icons.trending_down_rounded,
                AppColors.warning,
                onTap: () => _showTransferDialog(
                  'Investment to E-Wallet',
                  'investment_to_e',
                  widget.investmentWalletBalance,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferOption(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTransferDialog(
    String title,
    String transferType,
    double maxAmount,
  ) async {
    showDialog(
      context: context,
      builder: (context) => TransferDialog(
        title: title,
        transferType: transferType,
        maxAmount: maxAmount,
        eWalletBalance: widget.eWalletBalance,
        investmentWalletBalance: widget.investmentWalletBalance,
        onTransferConfirmed: _processTransfer,
      ),
    );
  }

  Future<void> _processTransfer(
    double amount,
    String transferType,
  ) async {
    try {
      final walletService = WalletService();
      final response = await walletService.transferFunds(
        amount: amount,
        transferType: transferType,
      );

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Transfer successful!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to refresh wallet data
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Transfer failed!'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

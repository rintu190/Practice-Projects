import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import 'package:flutter_mlm_investment/features/earnings/data/providers/earnings_provider.dart';

class EarningsBreakdownScreen extends StatefulWidget {
  const EarningsBreakdownScreen({super.key});

  @override
  State<EarningsBreakdownScreen> createState() => _EarningsBreakdownScreenState();
}

class _EarningsBreakdownScreenState extends State<EarningsBreakdownScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarningsProvider>().fetchEarningsBreakdown();
    });
  }

  Future<void> _handleWithdraw(double amount) async {
    if (amount <= 0) return;

    final success = await context.read<EarningsProvider>().withdrawEarnings(amount);
    
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Earnings withdrawn to wallet successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<EarningsProvider>().error ?? 'Withdrawal failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Breakdown'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<EarningsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.breakdown == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.breakdown == null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final data = provider.breakdown;
          if (data == null) return const SizedBox();

          final currentBalance = double.tryParse(data['current_balance'].toString()) ?? 0.0;
          final totalEarned = double.tryParse(data['total_earned'].toString()) ?? 0.0;
          final totalWithdrawn = double.tryParse(data['total_withdrawn'].toString()) ?? 0.0;
          
          final commissions = data['commissions'];
          final profits = data['profits'];

          return RefreshIndicator(
            onRefresh: () => provider.fetchEarningsBreakdown(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF8B84FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Available to Withdraw',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.formatCurrency(currentBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (currentBalance > 0)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: provider.isLoading 
                                  ? null 
                                  : () => _handleWithdraw(currentBalance),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: provider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Withdraw All to Wallet',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Earned',
                          Formatters.formatCurrency(totalEarned),
                          Icons.monetization_on,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Withdrawn',
                          Formatters.formatCurrency(totalWithdrawn),
                          Icons.account_balance_wallet,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Commissions Section
                  const Text(
                    'Commissions Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBreakdownList(
                    commissions['breakdown'] as List? ?? [],
                    isCommission: true,
                  ),
                  const SizedBox(height: 24),

                  // Profits Section
                  const Text(
                    'Investment Profits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBreakdownList(
                    profits['breakdown'] as List? ?? [],
                    isCommission: false,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownList(List items, {required bool isCommission}) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'No earnings yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final title = isCommission 
            ? _formatCommissionType(item['type']) 
            : (item['product'] ?? 'Unknown Product');
        final amount = double.tryParse(item['amount'].toString()) ?? 0.0;
        final count = item['count'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isCommission ? Colors.blue : Colors.purple).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCommission ? Icons.people_outline : Icons.trending_up,
                  color: isCommission ? Colors.blue : Colors.purple,
                  size: 20,
                ),
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$count transaction${count != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatCommissionType(String type) {
    switch (type) {
      case 'direct_sponsor':
        return 'Direct Referral';
      case 'level_bonus':
        return 'Level Bonus';
      case 'matching_bonus':
        return 'Matching Bonus';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/user_investment.dart';
import '../../data/services/investment_service.dart';
import 'package:provider/provider.dart';
import '../../../dashboard/data/providers/dashboard_provider.dart';

class InvestmentDetailScreen extends StatefulWidget {
  final UserInvestment investment;

  const InvestmentDetailScreen({super.key, required this.investment});

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  final _investmentService = InvestmentService();
  bool _isLoading = false;
  late UserInvestment _investment;

  @override
  void initState() {
    super.initState();
    _investment = widget.investment;
  }

  Future<void> _handleAction(String action) async {
    setState(() => _isLoading = true);
    try {
      if (action == 'sell') {
        await _investmentService.sellInvestment(_investment.id);
        if (mounted) Navigator.pop(context, true); // Return true to refresh
      } else if (action == 'renew') {
        // Implement renew logic (maybe show modal first)
      } else if (action == 'toggle_auto_renew') {
        await _investmentService.toggleAutoRenew(
            _investment.id, !_investment.autoRenew);
        // Refresh local state or fetch updated investment
        setState(() {
          // Optimistic update or re-fetch
          // For now, let's just toggle local state if we had a full object update mechanism
          // But UserInvestment is immutable. We should probably re-fetch or just pop with refresh.
        });
        if (mounted) {
          context.read<DashboardProvider>().refreshAll();
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSellConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sell Investment?'),
        content: const Text(
            'Are you sure you want to sell this investment early? Early withdrawal penalty may apply.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAction('sell');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sell Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildProgressCard(progress),
            const SizedBox(height: 24),
            _buildProfitProjection(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            if (_investment.status == 'active') _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  double _calculateProgress() {
    if (_investment.maturityDate == null) return 0.0;
    final totalDuration =
        _investment.maturityDate!.difference(_investment.createdAt).inSeconds;
    final elapsed = DateTime.now().difference(_investment.createdAt).inSeconds;
    if (totalDuration == 0) return 1.0;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _investment.productName ?? 'Investment #${_investment.id}',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(_investment.amount),
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _investment.status.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Maturity Progress',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          color: AppColors.primary,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Started: ${Formatters.formatDate(_investment.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (_investment.maturityDate != null)
              Text(
                'Ends: ${Formatters.formatDate(_investment.maturityDate!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitProjection() {
    if (_investment.maturityDate == null || _investment.status != 'active') {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final maturityDate = _investment.maturityDate!;
    final totalDays = maturityDate.difference(_investment.createdAt).inDays;
    final elapsedDays = now.difference(_investment.createdAt).inDays;
    final remainingDays =
        maturityDate.difference(now).inDays.clamp(0, totalDays);

    // Calculate daily profit rate (simplified - assumes daily distribution)
    final dailyProfit = _investment.amount * (_investment.roiPercentage / 100);

    // Project remaining profit
    final projectedProfit = dailyProfit * remainingDays;
    final totalProjected = _investment.totalProfitEarned + projectedProfit;
    final finalAmount = _investment.amount + totalProjected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Profit Projection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _projectionRow('Days Elapsed', '$elapsedDays days'),
          _projectionRow('Days Remaining', '$remainingDays days'),
          const Divider(height: 24),
          _projectionRow('Earned So Far',
              Formatters.formatCurrency(_investment.totalProfitEarned)),
          _projectionRow(
              'Projected Remaining', Formatters.formatCurrency(projectedProfit),
              color: Colors.orange),
          const Divider(height: 24),
          _projectionRow(
              'Total Profit (Est.)', Formatters.formatCurrency(totalProjected),
              isBold: true, color: AppColors.success),
          _projectionRow(
              'Final Amount (Est.)', Formatters.formatCurrency(finalAmount),
              isBold: true, color: AppColors.primary),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Projection based on current ROI rate. Actual profit may vary.',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _projectionRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
            'Total Profit',
            Formatters.formatCurrency(_investment.totalProfitEarned),
            Icons.trending_up,
            Colors.green),
        _buildStatCard('ROI Rate', '${_investment.roiPercentage}%',
            Icons.percent, Colors.blue),
        _buildStatCard(
            'Auto Renew',
            _investment.autoRenew ? 'ON' : 'OFF',
            Icons.autorenew,
            _investment.autoRenew ? Colors.green : Colors.grey),
        _buildStatCard(
            'Last Profit',
            _investment.lastProfitDate != null
                ? Formatters.formatDate(_investment.lastProfitDate!)
                : 'N/A',
            Icons.calendar_today,
            Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed:
                _isLoading ? null : () => _handleAction('toggle_auto_renew'),
            icon: Icon(_investment.autoRenew ? Icons.cancel : Icons.autorenew),
            label: Text(_investment.autoRenew
                ? 'Disable Auto-Renew'
                : 'Enable Auto-Renew'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _showSellConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            icon: const Icon(Icons.sell),
            label: const Text('Sell Investment'),
          ),
        ),
      ],
    );
  }
}

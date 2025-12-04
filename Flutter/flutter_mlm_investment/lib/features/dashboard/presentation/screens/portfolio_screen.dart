import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../../investment/presentation/screens/investment_categories_screen.dart';
import '../../../investment/presentation/screens/investment_detail_screen.dart';
import '../../../investment/presentation/screens/investment_history_screen.dart';
import '../../../investment/data/models/user_investment.dart';
import '../../../pnl/presentation/screens/daily_pnl_screen.dart';


class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final dashboardData = provider.dashboardData;
        final portfolio = provider.portfolio;

        final totalInvested = double.tryParse(
                (dashboardData?['investment']?['total_invested'] ?? 0)
                    .toString()) ??
            0.0;
        final currentValue = double.tryParse(
                (dashboardData?['investment']?['current_value'] ?? 0)
                    .toString()) ??
            0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Portfolio'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InvestmentHistoryScreen(),
                    ),
                  );
                },
                tooltip: 'Investment History',
              ),
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyPnlScreen(),
                    ),
                  );
                },
                tooltip: 'Daily P&L',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InvestmentCategoriesScreen()),
              ).then((_) {
                // Refresh portfolio when returning
                context.read<DashboardProvider>().fetchPortfolio();
              });
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label:
                const Text('Invest Now', style: TextStyle(color: Colors.white)),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchPortfolio(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portfolio Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildValueColumn(
                                context,
                                'Invested',
                                totalInvested,
                                AppColors.textPrimary,
                              ),
                              _buildValueColumn(
                                context,
                                'Profit',
                                currentValue - totalInvested,
                                AppColors.success,
                              ),
                              _buildValueColumn(
                                context,
                                'Total Value',
                                currentValue,
                                AppColors.primary,
                                isBold: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Pie Chart
                          if (portfolio.isNotEmpty) ...[
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection ==
                                                null) {
                                          _touchedIndex = -1;
                                          return;
                                        }
                                        _touchedIndex = pieTouchResponse
                                            .touchedSection!
                                            .touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                  sections: _showingSections(
                                      portfolio, totalInvested),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Legend (Simplified for now, showing top 3)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildLegendItem(
                                    AppColors.primary, 'Active', '100%'),
                              ],
                            ),
                          ] else
                            const Center(
                              child: Text('No active investments'),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Active Investments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Investment List
                    if (portfolio.isEmpty)
                      const Center(child: Text('No investments found'))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: portfolio.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildInvestmentItem(portfolio[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _showingSections(
      List<dynamic> portfolio, double total) {
    if (total == 0) return [];

    return List.generate(portfolio.length > 3 ? 3 : portfolio.length, (i) {
      final item = portfolio[i];
      final amount = double.tryParse((item['amount'] ?? 0).toString()) ?? 0.0;
      final percentage = (amount / total) * 100;

      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final colors = [
        AppColors.primary,
        AppColors.accent,
        Colors.orange,
        Colors.blue
      ];
      final color = colors[i % colors.length];

      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvestmentItem(dynamic plan) {
    final amount = double.tryParse((plan['amount'] ?? 0).toString()) ?? 0.0;
    final roi = plan['roi_percentage'] ?? '0';
    final dateStr = plan['created_at'] ?? '';
    final type = plan['product_type'] ?? 'Standard';
    final frequency = plan['roi_frequency'] ?? 'Daily';
    final duration = plan['duration_days'] ?? 0;
    final status = plan['status'] ?? 'active';

    String formattedDate = dateStr;
    try {
      formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {}

    String formattedMaturityDate = plan['maturity_date'] ?? '';
    try {
      if (formattedMaturityDate.isNotEmpty) {
        formattedMaturityDate = DateFormat('dd MMM yyyy').format(DateTime.parse(formattedMaturityDate));
      }
    } catch (_) {}

    return InkWell(
      onTap: () {
        try {
          final investment = UserInvestment.fromJson(plan);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  InvestmentDetailScreen(investment: investment),
            ),
          ).then((_) {
            context.read<DashboardProvider>().fetchPortfolio();
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open details: $e')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon, Name, Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['product_name'] ?? 'Investment',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        type.toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'active' 
                        ? Colors.green.withOpacity(0.1) 
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: status == 'active' ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Details Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn('Price', Formatters.formatCurrency(amount)),
                _buildDetailColumn('Plan', '$roi% / $frequency'),
                _buildDetailColumn('Duration', '$duration Days'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn('Invested', formattedDate),
                _buildDetailColumn('Maturity', formattedMaturityDate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildValueColumn(
    BuildContext context,
    String label,
    double value,
    Color color, {
    bool isBold = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Formatters.formatCurrency(value),
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

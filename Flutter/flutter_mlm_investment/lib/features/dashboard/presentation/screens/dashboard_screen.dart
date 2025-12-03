import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_mlm_investment/features/dashboard/presentation/screens/portfolio_screen.dart';
import 'package:flutter_mlm_investment/features/team/presentation/screens/referral_screen.dart';
import 'package:provider/provider.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../widgets/metric_card.dart';
import 'team_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import '../widgets/performance_chart.dart';
import '../widgets/rank_card.dart';
import '../widgets/earnings_card.dart';
import '../../../admin/presentation/screens/admin_panel_screen.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../../packages/presentation/screens/packages_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refreshAll();
    });
  }

  final List<Widget> _screens = [
    const HomeTab(),
    const PortfolioScreen(),
    const TeamScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Portfolio',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = provider.dashboardData;
        if (data == null) {
          return const Center(child: Text('Failed to load data'));
        }

        final user = data['user'] ?? {};
        final wallet = data['wallet'] ?? {};
        final investment = data['investment'] ?? {};
        final team = data['team'] ?? {};
        final todayPnl = data['today_pnl'] ?? 0;

        // Debug logging
        debugPrint(
            'Dashboard Data: user=$user, wallet=$wallet, investment=$investment, team=$team');
        debugPrint(
            'User rank: ${user['rank']}, next_rank: ${user['next_rank']}');

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => provider.refreshAll(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          Text(
                            user['name'] ?? 'User',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Earnings Card
                  if (wallet != null && wallet['total_earned'] != null)
                    EarningsCard(
                      amount: Formatters.formatCurrency(
                          (wallet['total_earned'] ?? 0).toDouble()),
                    ),
                  if (wallet != null && wallet['total_earned'] != null)
                    const SizedBox(height: 24),

                  // Rank Card
                  if (user != null && user['rank'] != null)
                    RankCard(
                      currentRank: user['rank'] ?? 'Member',
                      nextRankData: user['next_rank'],
                    ),
                  if (user != null && user['rank'] != null)
                    const SizedBox(height: 24),

                  // Metrics Grid
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      MetricCard(
                        title: 'E-Wallet',
                        value: Formatters.formatCurrency(
                            (wallet['balance'] ?? 0).toDouble()),
                        icon: Icons.account_balance_wallet_rounded,
                        color: Colors.blue,
                        subtitle: '+12%', // TODO: Calculate % change
                      ),
                      MetricCard(
                        title: 'Investments',
                        value: Formatters.formatCurrency(
                            (investment['current_value'] ?? 0).toDouble()),
                        icon: Icons.trending_up_rounded,
                        color: Colors.green,
                        subtitle: 'Active',
                      ),
                      MetricCard(
                        title: 'Total Team',
                        value: (team['total_members'] ?? 0).toString(),
                        icon: Icons.people_alt_rounded,
                        color: Colors.orange,
                        subtitle: '+${team['active_members']} Active',
                      ),
                      MetricCard(
                        title: 'Today\'s P&L',
                        value: Formatters.formatCurrency(
                            (todayPnl ?? 0).toDouble()),
                        icon: Icons.attach_money_rounded,
                        color: Colors.purple,
                        subtitle: '+1.2%', // TODO: Calculate % change
                      ),
                    ],
                  ),
                  // Unrealized P&L Card
                  if (investment['total_invested'] > 0) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Unrealized P&L',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ((todayPnl ?? 0) >= 0
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(todayPnl ?? 0) >= 0 ? '+' : ''}${Formatters.formatCurrency((todayPnl ?? 0).toDouble())} Today',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (todayPnl ?? 0) >= 0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.formatCurrency(
                                    (investment['unrealized_pnl'] ?? 0).toDouble()),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          (investment['unrealized_pnl'] ?? 0) >=
                                                  0
                                              ? AppColors.success
                                              : AppColors.error,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'Total Return',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Performance Chart
                  PerformanceChart(
                    historyData: provider.pnlHistory,
                    selectedDays: provider.pnlDays,
                    onDaysChanged: (days) =>
                        provider.fetchPnlHistory(days: days),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final isAdmin = authProvider.isAdmin;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildQuickAction(
                            context,
                            icon: Icons.person_add_alt_1_outlined,
                            label: 'Invite',
                            color: AppColors.accent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ReferralScreen()),
                              );
                            },
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.support_agent,
                            label: 'Support',
                            color: Colors.orange,
                            onTap: () {},
                          ),
                          if (isAdmin)
                            _buildQuickAction(
                              context,
                              icon: Icons.admin_panel_settings,
                              label: 'Admin',
                              color: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminPanelScreen()),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

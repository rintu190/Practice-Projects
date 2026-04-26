import 'package:flutter/material.dart';
import '../models/position.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';
import '../widgets/position_card.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final MockDataService _dataService = MockDataService();
  late User _user;
  late List<Position> _positions;

  @override
  void initState() {
    super.initState();
    _dataService.initialize();
    _user = _dataService.getUser();
    _positions = _dataService.getUserPositions();
  }

  @override
  Widget build(BuildContext context) {
    final totalValue = _user.balance + _calculateTotalPositionValue();
    final totalProfit = _calculateTotalProfit();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info Header
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${_user.username}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Portfolio Value Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Value',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalValue.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard(
                        'Available',
                        '\$${_user.balance.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Positions',
                        '\$${_calculateTotalPositionValue().toStringAsFixed(2)}',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Profit/Loss',
                        '\$${totalProfit.toStringAsFixed(2)}',
                        Icons.trending_up,
                        totalProfit >= 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Positions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Positions (${_positions.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_positions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No positions yet',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _positions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return PositionCard(position: _positions[index]);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalPositionValue() {
    return _positions.fold<double>(0, (sum, pos) => sum + pos.currentValue);
  }

  double _calculateTotalProfit() {
    return _positions.fold<double>(0, (sum, pos) => sum + pos.profit);
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

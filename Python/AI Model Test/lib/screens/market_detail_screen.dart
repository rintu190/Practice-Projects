import 'package:flutter/material.dart';
import '../models/market.dart';
import '../widgets/trading_panel.dart';
import '../widgets/market_chart.dart';

class MarketDetailScreen extends StatefulWidget {
  final Market? market;

  const MarketDetailScreen({Key? key, this.market}) : super(key: key);

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  late Market market;
  String _selectedOutcome = 'YES';

  @override
  void initState() {
    super.initState();
    market = widget.market ??
        Market(
          id: '1',
          question: 'Will Bitcoin reach \$100K by end of 2024?',
          description: 'Bitcoin price prediction for year-end 2024',
          category: 'Cryptocurrency',
          endDate: DateTime.now().add(const Duration(days: 200)),
          yesPrice: 0.68,
          noPrice: 0.32,
          volume: 2500000,
          traders: 12500,
          imageUrl: 'https://via.placeholder.com/400x200?text=Bitcoin',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Header with Image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: DecorationImage(
                  image: NetworkImage(market.imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),

            // Question and Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Text(
                    market.question,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  // Category Badge
                  Chip(
                    label: Text(market.category),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),

                  // Market Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('24H Volume',
                          '\$${(market.volume / 1000000).toStringAsFixed(1)}M'),
                      _buildStatColumn(
                          'Traders', '${market.traders}'),
                      _buildStatColumn('Closes In', market.timeUntilClose),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    market.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Chart
                  Text(
                    'Price Chart',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  MarketChart(market: market),
                  const SizedBox(height: 24),

                  // Probability Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Probabilities',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildProbabilityBar(
                          'YES',
                          market.yesPrice,
                          Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _buildProbabilityBar(
                          'NO',
                          market.noPrice,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Trading Panel
                  TradingPanel(
                    market: market,
                    onOutcomeSelected: (outcome) {
                      setState(() {
                        _selectedOutcome = outcome;
                      });
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildProbabilityBar(String label, double probability, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${(probability * 100).toStringAsFixed(1)}¢',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: probability,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

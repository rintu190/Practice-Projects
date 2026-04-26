import 'package:flutter/material.dart';
import '../models/position.dart';

class PositionCard extends StatelessWidget {
  final Position position;

  const PositionCard({Key? key, required this.position}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isProfit = position.profit >= 0;
    final profitColor = isProfit ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position.marketQuestion,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: position.outcome == 'YES'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          position.outcome,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: position.outcome == 'YES'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${position.profit >= 0 ? '+' : ''}\$${position.profit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: profitColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${position.profitPercent >= 0 ? '+' : ''}${position.profitPercent.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: profitColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),

            // Details Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildDetail(
                  'Shares',
                  position.shares.toStringAsFixed(2),
                  context,
                ),
                _buildDetail(
                  'Avg Price',
                  '${(position.averagePrice * 100).toStringAsFixed(2)}¢',
                  context,
                ),
                _buildDetail(
                  'Current',
                  '${(position.currentPrice * 100).toStringAsFixed(2)}¢',
                  context,
                ),
                _buildDetail(
                  'Cost',
                  '\$${position.cost.toStringAsFixed(2)}',
                  context,
                ),
                _buildDetail(
                  'Value',
                  '\$${position.currentValue.toStringAsFixed(2)}',
                  context,
                ),
                _buildDetail(
                  'Date',
                  '${position.boughtAt.month}/${position.boughtAt.day}/${position.boughtAt.year}',
                  context,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Sold ${position.shares} shares for \$${position.currentValue.toStringAsFixed(2)}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Sell'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening market details')),
                      );
                    },
                    child: const Text('Market'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

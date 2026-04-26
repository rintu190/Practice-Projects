import 'package:flutter/material.dart';
import '../models/market.dart';

class MarketCard extends StatelessWidget {
  final Market market;

  const MarketCard({Key? key, required this.market}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 150,
                color: Colors.grey[300],
                child: Image.network(
                  market.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category Badge
            Chip(
              label: Text(market.category),
              labelStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              backgroundColor: Colors.blue.withOpacity(0.2),
            ),
            const SizedBox(height: 8),

            // Question
            Text(
              market.question,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Probability Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Probability',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(market.yesPrice * 100).toStringAsFixed(1)}¢',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: market.yesPrice,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Market Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  icon: Icons.trending_up,
                  label: '\$${(market.volume / 1000000).toStringAsFixed(1)}M',
                  tooltip: 'Volume',
                ),
                _buildInfoChip(
                  icon: Icons.people,
                  label: '${market.traders}',
                  tooltip: 'Traders',
                ),
                _buildInfoChip(
                  icon: Icons.schedule,
                  label: market.timeUntilClose,
                  tooltip: 'Closes in',
                  color: market.isClosing ? Colors.red : Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String tooltip,
    Color color = Colors.blue,
  }) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

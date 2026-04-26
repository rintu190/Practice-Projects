import 'package:flutter/material.dart';
import '../models/market.dart';

class MarketChart extends StatelessWidget {
  final Market market;

  const MarketChart({Key? key, required this.market}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate mock price data
    final List<double> priceHistory = _generatePriceHistory(market.yesPrice);
    final maxPrice = priceHistory.reduce((a, b) => a > b ? a : b);
    final minPrice = priceHistory.reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;

    return Column(
      children: [
        // Chart
        Container(
          height: 150,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: PriceChartPainter(
              prices: priceHistory,
              maxPrice: maxPrice,
              minPrice: minPrice,
            ),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem('High', '\$${maxPrice.toStringAsFixed(2)}'),
            _buildLegendItem('Current', '\$${market.yesPrice.toStringAsFixed(2)}'),
            _buildLegendItem('Low', '\$${minPrice.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }

  List<double> _generatePriceHistory(double currentPrice) {
    final random = _SimpleRandom(42); // Seeded for consistency
    List<double> prices = [currentPrice];
    
    for (int i = 0; i < 30; i++) {
      double change = (random.nextDouble() - 0.5) * 0.1;
      double newPrice = (prices.last + change).clamp(0.1, 0.9);
      prices.add(newPrice);
    }
    
    return prices;
  }

  Widget _buildLegendItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class PriceChartPainter extends CustomPainter {
  final List<double> prices;
  final double maxPrice;
  final double minPrice;

  PriceChartPainter({
    required this.prices,
    required this.maxPrice,
    required this.minPrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final priceRange = maxPrice - minPrice;
    if (priceRange == 0) return;

    // Draw gradient fill
    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final normalizedPrice = (prices[i] - minPrice) / priceRange;
      final y = size.height - (normalizedPrice * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Close the path for fill
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);

    // Draw line
    final linePath = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final normalizedPrice = (prices[i] - minPrice) / priceRange;
      final y = size.height - (normalizedPrice * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, paint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    for (int i = 0; i < 5; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Simple pseudo-random number generator for consistency
class _SimpleRandom {
  int _seed;

  _SimpleRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}

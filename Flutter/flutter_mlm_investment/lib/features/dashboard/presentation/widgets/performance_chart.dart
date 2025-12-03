import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class PerformanceChart extends StatefulWidget {
  final List<dynamic> historyData;
  final int selectedDays;
  final Function(int) onDaysChanged;

  const PerformanceChart({
    super.key,
    required this.historyData,
    this.selectedDays = 30,
    required this.onDaysChanged,
  });

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.historyData.isEmpty) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text('No performance data available'),
        ),
      );
    }
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
          // Header with time range selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _buildTimeRangeSelector(),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 200,
            child: LineChart(
              _buildLineChartData(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeButton('7D', 7),
          _buildTimeButton('30D', 30),
          _buildTimeButton('90D', 90),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String label, int days) {
    final isSelected = widget.selectedDays == days;
    return GestureDetector(
      onTap: () => widget.onDaysChanged(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final spots = <FlSpot>[];
    
    try {
      for (int i = 0; i < widget.historyData.length; i++) {
        final item = widget.historyData[i];
        // Use cumulative value from API if available, otherwise calculate
        final cumulative = item['cumulative'] ?? 0;
        final cumulativeValue = double.tryParse(cumulative.toString()) ?? 0.0;
        spots.add(FlSpot(i.toDouble(), cumulativeValue));
      }
    } catch (e) {
      debugPrint('Error building chart spots: $e');
    }

    if (spots.isEmpty) {
      // Return a default chart with a single point at 0
      spots.add(FlSpot(0, 0));
    }

    // Determine if overall trend is positive or negative
    final isPositive = spots.length > 1 && spots.last.y >= spots.first.y;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (widget.historyData.length / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= widget.historyData.length) {
                return const SizedBox();
              }
              final date = widget.historyData[value.toInt()]['date'] ?? '';
              final parts = date.split('-');
              if (parts.length == 3) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${parts[2]}/${parts[1]}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '₹${(value / 1000).toStringAsFixed(0)}k',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
      minY: spots.isEmpty
          ? 0
          : (spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 0.9),
      maxY: spots.isEmpty
          ? 100
          : (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: isPositive ? Colors.green : Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = widget.historyData[spot.x.toInt()]['date'] ?? '';
              return LineTooltipItem(
                '₹${spot.y.toStringAsFixed(2)}\n$date',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

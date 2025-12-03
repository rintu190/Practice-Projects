import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RankCard extends StatelessWidget {
  final String currentRank;
  final Map<String, dynamic>? nextRankData;

  const RankCard({
    super.key,
    required this.currentRank,
    this.nextRankData,
  });

  @override
  Widget build(BuildContext context) {
    // Determine rank color
    Color rankColor;
    switch (currentRank.toLowerCase()) {
      case 'basic':
        rankColor = AppColors.primary;
        break;
      case 'bronze':
        rankColor = Colors.brown.shade300;
        break;
      case 'silver':
        rankColor = Colors.grey.shade400;
        break;
      case 'gold':
        rankColor = Colors.amber;
        break;
      case 'diamond':
        rankColor = Colors.blue.shade300;
        break;
      default:
        rankColor = AppColors.primary;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [rankColor, rankColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Rank',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentRank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          
          if (nextRankData != null) ...[
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next: ${nextRankData!['name']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(nextRankData!['overall_progress'] ?? 0).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (nextRankData!['overall_progress'] ?? 0) / 100,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Requirements
            Row(
              children: [
                _buildRequirement(
                  'Team',
                  nextRankData!['team_progress'] ?? 0,
                ),
                const SizedBox(width: 16),
                _buildRequirement(
                  'Investment',
                  nextRankData!['investment_progress'] ?? 0,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirement(String label, num progress) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${progress.toStringAsFixed(0)}% Done',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

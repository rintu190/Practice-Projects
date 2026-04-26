import 'package:flutter/material.dart';
import '../theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
             padding: const EdgeInsets.all(16),
             margin: const EdgeInsets.only(bottom: 24),
             decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
             ),
             child: const Row(
               children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                  SizedBox(width: 16),
                  Expanded(child: Text('Top Traders this Week', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18))),
               ],
             ),
          ),
          _buildRankTile(1, 'AlexTheWhale', 500000, true),
          _buildRankTile(2, 'BullishBob', 420000, false),
          _buildRankTile(3, 'CryptoKing', 310000, false),
          _buildRankTile(4, 'MemeLord', 280000, false),
          _buildRankTile(5, 'TradingBot44', 210000, false),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
          _buildRankTile(145, 'You', 10000, false, isMe: true),
        ],
      ),
    );
  }

  Widget _buildRankTile(int rank, String name, int amount, bool isTop, {bool isMe = false}) {
    Color medalColor;
    if (rank == 1) medalColor = Colors.amber;
    else if (rank == 2) medalColor = Colors.grey.shade400; // silver
    else if (rank == 3) medalColor = Colors.brown.shade300; // bronze
    else medalColor = Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: isMe 
          ? BoxDecoration(color: AppTheme.accentPurple.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3))) 
          : null,
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              backgroundColor: isTop ? medalColor : AppTheme.cardColor,
              child: isTop 
                 ? const Icon(Icons.star, color: Colors.white, size: 20)
                 : Text('#$rank', style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        title: Text(name, style: TextStyle(fontWeight: isMe || isTop ? FontWeight.w800 : FontWeight.w600, color: isMe ? AppTheme.accentPurple : AppTheme.textColor)),
        trailing: Text('₹$amount', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isMe ? AppTheme.accentPurple : AppTheme.yesColor)),
      ),
    );
  }
}

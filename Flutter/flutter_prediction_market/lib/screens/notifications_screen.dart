import 'package:flutter/material.dart';
import '../theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          _buildNotificationCard('Market closing soon', 'Will CSK win today? closes in 1h.', Icons.timer, Colors.orange),
          _buildNotificationCard('Deposit Successful', '₹1500 has been added to your wallet.', Icons.account_balance_wallet, AppTheme.yesColor),
          const SizedBox(height: 24),
          const Text('Earlier', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          _buildNotificationCard('You won ₹500 🎉', 'Your prediction on Liger Movie was correct. Winnings have been credited to your wallet.', Icons.emoji_events, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String title, String body, IconData icon, Color color) {
    return Card(
      color: AppTheme.cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(16),
         side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(body, style: const TextStyle(color: AppTheme.textMuted)),
          ),
        ),
      ),
    );
  }
}

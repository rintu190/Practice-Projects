import 'package:flutter/material.dart';
import '../theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.premiumCardDecoration.copyWith(
                border: Border.all(color: AppTheme.accentPurple.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Text('Available Balance', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('₹5,000.00', style: TextStyle(color: AppTheme.textColor, fontSize: 36, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Add Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppTheme.accentPurple, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Withdraw', style: TextStyle(color: AppTheme.accentPurple, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Transaction History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textColor)),
            const SizedBox(height: 16),
            
            _buildTxnCard('Deposit via UPI', 'Apr 01, 2026', 1500, true),
            _buildTxnCard('Trade: CSK vs MI (Buy YES)', 'Mar 31, 2026', 500, false),
            _buildTxnCard('Trade: NIFTY 50 (Buy NO)', 'Mar 30, 2026', 1000, false),
            _buildTxnCard('Winnings: Liger Box Office', 'Mar 28, 2026', 2400, true),
          ],
        ),
      ),
    );
  }

  Widget _buildTxnCard(String title, String date, int amount, bool isCredit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textColor)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹$amount',
            style: TextStyle(
              color: isCredit ? Colors.green : AppTheme.textColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

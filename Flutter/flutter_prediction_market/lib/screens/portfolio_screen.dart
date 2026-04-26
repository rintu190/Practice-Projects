import 'package:flutter/material.dart';
import '../theme.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Portfolio', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.textColor)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Stats Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accentPurple, AppTheme.accentPurple.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppTheme.accentPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('₹18,540.50', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statBlock('Invested', '₹12,000', Colors.white),
                        _statBlock('Cash Balance', '₹5,000', Colors.white),
                        _statBlock('Total Profit', '+₹1,540', Colors.greenAccent),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Active Positions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.textColor)),
              const SizedBox(height: 16),
              
              _buildHoldingCard(
                category: 'CRICKET',
                title: 'CSK vs MI - Who will win?',
                outcome: 'YES',
                shares: 100,
                avgPrice: 50,
                currentPrice: 62,
              ),
              _buildHoldingCard(
                category: 'POLITICS',
                title: 'NDA to win 2024 Elections?',
                outcome: 'NO',
                shares: 250,
                avgPrice: 40,
                currentPrice: 25,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBlock(String label, String value, Color valColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valColor, fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildHoldingCard({
    required String category,
    required String title,
    required String outcome,
    required int shares,
    required int avgPrice,
    required int currentPrice,
  }) {
    int invested = shares * avgPrice;
    int currentValue = shares * currentPrice;
    int profit = currentValue - invested;
    bool isProfit = profit >= 0;
    Color profitColor = isProfit ? AppTheme.yesColor : AppTheme.noColor;
    String profitStr = isProfit ? '+₹$profit' : '-₹${profit.abs()}';
    Color outcomeColor = outcome == 'YES' ? AppTheme.yesColor : AppTheme.noColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(color: AppTheme.accentPurple, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: outcomeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text('$outcome $shares Shares', style: TextStyle(color: outcomeColor, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 1.3, color: AppTheme.textColor)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile('Invested', '₹$invested', AppTheme.textColor),
              _infoTile('Current', '₹$currentValue', AppTheme.textColor),
              _infoTile('Returns', profitStr, profitColor, isRight: true),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Avg Price: ₹$avgPrice', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text('Current Price: ₹$currentPrice', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoTile(String label, String val, Color valColor, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(color: valColor, fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

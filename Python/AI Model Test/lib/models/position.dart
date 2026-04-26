class Position {
  final String id;
  final String marketId;
  final String marketQuestion;
  final String outcome; // 'YES' or 'NO'
  final double shares;
  final double averagePrice;
  final double currentPrice;
  final DateTime boughtAt;

  Position({
    required this.id,
    required this.marketId,
    required this.marketQuestion,
    required this.outcome,
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    required this.boughtAt,
  });

  double get cost => shares * averagePrice;
  double get currentValue => shares * currentPrice;
  double get profit => currentValue - cost;
  double get profitPercent => (profit / cost * 100);
}

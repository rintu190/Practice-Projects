class User {
  final String id;
  final String username;
  final String email;
  final double balance;
  final double totalProfit;
  final int totalTrades;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.balance,
    required this.totalProfit,
    required this.totalTrades,
  });

  double get totalValue => balance + totalProfit;
}

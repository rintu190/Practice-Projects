class UserInvestment {
  final int id;
  final int userId;
  final int productId;
  final double amount;
  final double roiPercentage;
  final DateTime createdAt;
  final DateTime? maturityDate;
  final DateTime? lastProfitDate;
  final double totalProfitEarned;
  final bool autoRenew;
  final String status; // 'active', 'matured', 'withdrawn', 'renewed'
  final String? productName; // Optional, joined from product table usually

  UserInvestment({
    required this.id,
    required this.userId,
    required this.productId,
    required this.amount,
    required this.roiPercentage,
    required this.createdAt,
    this.maturityDate,
    this.lastProfitDate,
    required this.totalProfitEarned,
    required this.autoRenew,
    required this.status,
    this.productName,
  });

  factory UserInvestment.fromJson(Map<String, dynamic> json) {
    return UserInvestment(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      amount: double.parse(json['amount'].toString()),
      roiPercentage: double.parse((json['roi_percentage'] ?? 0).toString()),
      createdAt: DateTime.parse(json['created_at']),
      maturityDate: json['maturity_date'] != null ? DateTime.parse(json['maturity_date']) : null,
      lastProfitDate: json['last_profit_date'] != null ? DateTime.parse(json['last_profit_date']) : null,
      totalProfitEarned: double.parse((json['total_profit_earned'] ?? 0).toString()),
      autoRenew: json['auto_renew'] == 1 || json['auto_renew'] == true,
      status: json['status'] ?? 'active',
      productName: json['product_name'],
    );
  }
}

class Pnl {
  final int id;
  final int investmentId;
  final int userId;
  final int productId;
  final DateTime pnlDate;
  final double profitAmount;
  final double lossAmount;
  final double netPnl;
  final double investmentValueBefore;
  final double investmentValueAfter;
  final String? notes;

  Pnl({
    required this.id,
    required this.investmentId,
    required this.userId,
    required this.productId,
    required this.pnlDate,
    required this.profitAmount,
    required this.lossAmount,
    required this.netPnl,
    required this.investmentValueBefore,
    required this.investmentValueAfter,
    this.notes,
  });

  factory Pnl.fromJson(Map<String, dynamic> json) {
    return Pnl(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      investmentId: json['investment_id'] is int
          ? json['investment_id']
          : int.parse(json['investment_id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      productId: json['product_id'] is int
          ? json['product_id']
          : int.parse(json['product_id'].toString()),
      pnlDate: DateTime.parse(json['pnl_date']),
      profitAmount: double.parse(json['profit_amount'].toString()),
      lossAmount: double.parse(json['loss_amount'].toString()),
      netPnl: double.parse(json['net_pnl'].toString()),
      investmentValueBefore:
          double.parse(json['investment_value_before'].toString()),
      investmentValueAfter:
          double.parse(json['investment_value_after'].toString()),
      notes: json['notes'],
    );
  }
}

class InvestmentProduct {
  final int id;
  final String name;
  final String description;
  final double minAmount;
  final double? maxAmount;
  final double roiPercentage;
  final int durationDays;
  final String productType; // 'instrument', 'fund', 'fixed_plan', 'profit_sharing'
  final String roiFrequency; // 'daily', 'weekly', 'monthly', 'maturity'
  final bool autoRenewEnabled;
  final bool compoundInterest;
  final String riskLevel; // 'low', 'medium', 'high'
  final double earlyWithdrawalPenalty;
  final String? category;
  final String? tier;
  final String status;

  InvestmentProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.minAmount,
    this.maxAmount,
    required this.roiPercentage,
    required this.durationDays,
    required this.productType,
    required this.roiFrequency,
    required this.autoRenewEnabled,
    required this.compoundInterest,
    required this.riskLevel,
    required this.earlyWithdrawalPenalty,
    this.category,
    this.tier,
    required this.status,
  });

  factory InvestmentProduct.fromJson(Map<String, dynamic> json) {
    return InvestmentProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      minAmount: double.parse(json['min_amount'].toString()),
      maxAmount: json['max_amount'] != null ? double.parse(json['max_amount'].toString()) : null,
      roiPercentage: double.parse(json['roi_percentage'].toString()),
      durationDays: int.parse(json['duration_days'].toString()),
      productType: json['product_type'] ?? 'fixed_plan',
      roiFrequency: json['roi_frequency'] ?? 'maturity',
      autoRenewEnabled: json['auto_renew_enabled'] == 1 || json['auto_renew_enabled'] == true,
      compoundInterest: json['compound_interest'] == 1 || json['compound_interest'] == true,
      riskLevel: json['risk_level'] ?? 'medium',
      earlyWithdrawalPenalty: double.parse((json['early_withdrawal_penalty'] ?? 0).toString()),
      category: json['category'],
      tier: json['tier'],
      status: json['status'] ?? 'active',
    );
  }
}

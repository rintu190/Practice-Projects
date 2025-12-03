class PackagePurchase {
  final int id;
  final int userId;
  final int packageId;
  final double amount;
  final double gstAmount;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String invoiceNumber;
  final String purchasedAt;
  final String? expiresAt;
  final String? packageName;
  final String? packageType;

  PackagePurchase({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.amount,
    required this.gstAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.invoiceNumber,
    required this.purchasedAt,
    this.expiresAt,
    this.packageName,
    this.packageType,
  });

  factory PackagePurchase.fromJson(Map<String, dynamic> json) {
    return PackagePurchase(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      packageId: int.parse(json['package_id'].toString()),
      amount: double.parse(json['amount'].toString()),
      gstAmount: double.parse(json['gst_amount'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      paymentMethod: json['payment_method'] ?? 'wallet',
      status: json['status'] ?? 'pending',
      invoiceNumber: json['invoice_number'] ?? '',
      purchasedAt: json['purchased_at'] ?? '',
      expiresAt: json['expires_at'],
      packageName: json['package_name'],
      packageType: json['package_type'],
    );
  }
}

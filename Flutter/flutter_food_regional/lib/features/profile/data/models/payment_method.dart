class PaymentMethod {
  final String? id;
  final String type; // 'Card' or 'UPI'
  final String title;
  final String subtitle;

  PaymentMethod({
    this.id,
    required this.type,
    required this.title,
    required this.subtitle,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString(),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
    };
  }
}

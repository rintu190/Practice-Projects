class ShippingAddress {
  final int id;
  final String label;
  final String details;
  final bool isDefault;

  ShippingAddress({
    required this.id,
    required this.label,
    required this.details,
    required this.isDefault,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'],
      label: json['label'],
      details: json['details'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'details': details,
      'isDefault': isDefault,
    };
  }
}

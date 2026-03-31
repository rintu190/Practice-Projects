class PaymentMethod {
  final int id;
  final String type;
  final String lastFour;
  final String expiry;
  final String cardHolder;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.expiry,
    required this.cardHolder,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      lastFour: json['lastFour'],
      expiry: json['expiry'],
      cardHolder: json['cardHolder'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'lastFour': lastFour,
      'expiry': expiry,
      'cardHolder': cardHolder,
      'isDefault': isDefault,
    };
  }
}

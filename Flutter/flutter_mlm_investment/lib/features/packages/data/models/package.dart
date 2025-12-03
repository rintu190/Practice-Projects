class Package {
  final int id;
  final String name;
  final String description;
  final String type;
  final double price;
  final double gstRate;
  final int? validityDays;
  final List<String> features;
  final bool isActive;
  final double totalWithGst;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.gstRate,
    this.validityDays,
    required this.features,
    required this.isActive,
    required this.totalWithGst,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      price: double.parse(json['price'].toString()),
      gstRate: double.parse(json['gst_rate'].toString()),
      validityDays: json['validity_days'] != null 
          ? int.parse(json['validity_days'].toString()) 
          : null,
      features: json['features'] != null 
          ? List<String>.from(json['features']) 
          : [],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      totalWithGst: double.parse(json['total_with_gst'].toString()),
    );
  }

  double get gstAmount => (price * gstRate) / 100;
}

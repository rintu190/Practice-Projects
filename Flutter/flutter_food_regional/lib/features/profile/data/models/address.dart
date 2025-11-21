class Address {
  final String houseNumber;
  final String street;
  final String locality; // e.g., neighborhood or area
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final double? latitude;
  final double? longitude;

  Address({
    required this.houseNumber,
    required this.street,
    required this.locality,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
    this.latitude,
    this.longitude,
  });

  @override
  String toString() {
    final parts = [
      '\${houseNumber}, \${street}',
      locality,
      city,
      state,
      pincode,
      if (landmark != null && landmark!.isNotEmpty) landmark!
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }
}

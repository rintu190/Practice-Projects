class Address {
  final String? id;
  final String houseNumber;
  final String street;
  final String locality; // e.g., neighborhood or area
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Address({
    this.id,
    required this.houseNumber,
    required this.street,
    required this.locality,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get label => locality.isNotEmpty ? locality : street;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString(),
      houseNumber: json['house_number'] ?? '',
      street: json['street'] ?? '',
      locality: json['locality'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      landmark: json['landmark'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isDefault: (json['is_default'] == 1 || json['is_default'] == true || json['is_default'] == '1') ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'houseNumber': houseNumber,
      'street': street,
      'locality': locality,
      'city': city,
      'state': state,
      'pincode': pincode,
      if (landmark != null) 'landmark': landmark,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  @override
  String toString() {
    final parts = [
      '$houseNumber, $street',
      locality,
      city,
      state,
      pincode,
      if (landmark != null && landmark!.isNotEmpty) landmark!
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }
}

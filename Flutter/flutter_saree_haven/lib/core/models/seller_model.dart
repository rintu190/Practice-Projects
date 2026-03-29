class Seller {
  final String id;
  final String storeName;
  final String ownerName;
  final String location;
  final String imageUrl;
  final String bio;
  final double rating;
  final String contactEmail;
  final String mobileNumber;
  final String specialization;
  final int totalOrders;
  final int pendingOrders;
  final double totalEarning;

  const Seller({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.location,
    required this.imageUrl,
    required this.bio,
    required this.rating,
    required this.contactEmail,
    required this.mobileNumber,
    required this.specialization,
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.totalEarning = 0.0,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] ?? '',
      storeName: json['storeName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      bio: json['bio'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      contactEmail: json['contactEmail'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      specialization: json['specialization'] ?? '',
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      totalEarning: (json['totalEarning'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'ownerName': ownerName,
      'location': location,
      'imageUrl': imageUrl,
      'bio': bio,
      'rating': rating,
      'contactEmail': contactEmail,
      'mobileNumber': mobileNumber,
      'specialization': specialization,
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'totalEarning': totalEarning,
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? restaurantId;
  final String? profilePicture;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.restaurantId,
    this.profilePicture,
    this.latitude,
    this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      restaurantId: json['restaurant_id'] as String?,
      profilePicture: json['profile_picture'] as String?,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'restaurant_id': restaurantId,
      'profile_picture': profilePicture,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? restaurantId,
    String? profilePicture,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      restaurantId: restaurantId ?? this.restaurantId,
      profilePicture: profilePicture ?? this.profilePicture,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class Artisan {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String bio;
  final double rating;

  const Artisan({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.bio,
    required this.rating,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      bio: json['bio'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'bio': bio,
      'rating': rating,
    };
  }
}

import 'menu_item.dart';

class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final String deliveryTime;
  final String imageUrl;
  final List<MenuItem> menuItems;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    this.menuItems = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'].toString(),
      name: json['name'] as String,
      cuisine: json['cuisine'] as String,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      deliveryTime: json['delivery_time'] as String? ?? json['deliveryTime'] as String? ?? '30-40 min',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      menuItems: (json['menuItems'] as List?)
              ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'rating': rating,
      'delivery_time': deliveryTime,
      'image_url': imageUrl,
      'menuItems': menuItems.map((item) => item.toJson()).toList(),
    };
  }
}

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
    required this.menuItems,
  });
}

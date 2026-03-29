import 'artisan_model.dart';

class Saree {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String type;
  final List<String> imageUrls;
  final Artisan artisan;
  final String sellerId;
  final bool isCustomizable;
  final bool inStock;

  const Saree({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.type,
    required this.imageUrls,
    required this.artisan,
    required this.sellerId,
    this.isCustomizable = false,
    this.inStock = true,
  });

  factory Saree.fromJson(Map<String, dynamic> json) {
    return Saree(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      artisan: json['artisan'] != null ? Artisan.fromJson(json['artisan']) : Artisan(id: '', name: 'Unknown', location: '', imageUrl: '', bio: '', rating: 0),
      sellerId: json['sellerId'] ?? '',
      isCustomizable: json['isCustomizable'] ?? false,
      inStock: json['inStock'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'type': type,
      'imageUrls': imageUrls,
      'artisan': artisan.toJson(),
      'sellerId': sellerId,
      'isCustomizable': isCustomizable,
      'inStock': inStock,
    };
  }
}

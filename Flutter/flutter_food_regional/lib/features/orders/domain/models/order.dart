

class Order {
  final String? id;
  final String userId;
  final String restaurantId;
  final String addressId;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final String? restaurantName;
  final String? restaurantImage;
  final List<OrderItem>? items;

  Order({
    this.id,
    required this.userId,
    required this.restaurantId,
    required this.addressId,
    required this.totalAmount,
    required this.status,
    this.createdAt,
    this.restaurantName,
    this.restaurantImage,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      restaurantId: json['restaurant_id']?.toString() ?? '',
      addressId: json['address_id']?.toString() ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      restaurantName: json['restaurant_name'],
      restaurantImage: json['restaurant_image'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'addressId': addressId,
      'totalAmount': totalAmount,
      'status': status,
      if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String? id;
  final String menuItemId;
  final int quantity;
  final double price;
  final String? name;
  final String? imageUrl;

  OrderItem({
    this.id,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    this.name,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString(),
      menuItemId: json['menu_item_id']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'menuItemId': menuItemId,
      'quantity': quantity,
      'price': price,
    };
  }
}

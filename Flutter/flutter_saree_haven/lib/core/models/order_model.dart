import 'saree_model.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

OrderStatus _parseStatus(String statusStr) {
  switch (statusStr.toLowerCase()) {
    case 'processing': return OrderStatus.processing;
    case 'shipped': return OrderStatus.shipped;
    case 'delivered': return OrderStatus.delivered;
    case 'cancelled': return OrderStatus.cancelled;
    default: return OrderStatus.pending;
  }
}

class OrderItem {
  final Saree saree;
  final int quantity;
  final double price;

  OrderItem({
    required this.saree,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      saree: Saree.fromJson(json['saree'] ?? {}),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sareeId': saree.id,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  OrderStatus status;
  final String sellerId;

  Order({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerAddress,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.pending,
    required this.sellerId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItem> parsedItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      items: parsedItems,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : DateTime.now(),
      status: _parseStatus(json['status'] ?? 'pending'),
      sellerId: json['sellerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerAddress': customerAddress,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status.name,
      'sellerId': sellerId,
    };
  }

  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}

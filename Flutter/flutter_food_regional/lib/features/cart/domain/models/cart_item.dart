import '../../../home/domain/models/menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  final int quantity;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
  });

  CartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => menuItem.price * quantity;
}

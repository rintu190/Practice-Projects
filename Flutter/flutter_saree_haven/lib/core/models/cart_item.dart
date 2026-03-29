import 'saree_model.dart';

class CartItem {
  final Saree saree;
  int quantity;

  CartItem({
    required this.saree,
    this.quantity = 1,
  });

  double get totalPrice => saree.price * quantity;
}

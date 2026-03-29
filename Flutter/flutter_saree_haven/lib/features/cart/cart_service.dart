import 'package:flutter/material.dart';
import '../../core/models/saree_model.dart';
import '../../core/models/cart_item.dart';

class CartService extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values.fold(0.0, (total, item) => total + item.totalPrice);

  bool isInCart(String sareeId) => _items.containsKey(sareeId);

  void addToCart(Saree saree) {
    if (_items.containsKey(saree.id)) {
      _items[saree.id]!.quantity++;
    } else {
      _items[saree.id] = CartItem(saree: saree);
    }
    notifyListeners();
  }

  void removeFromCart(String sareeId) {
    _items.remove(sareeId);
    notifyListeners();
  }

  void incrementQuantity(String sareeId) {
    if (_items.containsKey(sareeId)) {
      _items[sareeId]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String sareeId) {
    if (_items.containsKey(sareeId)) {
      if (_items[sareeId]!.quantity > 1) {
        _items[sareeId]!.quantity--;
      } else {
        _items.remove(sareeId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

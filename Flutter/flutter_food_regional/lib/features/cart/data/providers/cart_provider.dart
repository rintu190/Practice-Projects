import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item.dart';
import '../../../home/domain/models/menu_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addToCart(MenuItem item) {
    final existingIndex = state.indexWhere((element) => element.menuItem.id == item.id);
    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(quantity: existingItem.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(menuItem: item)];
    }
  }

  void removeFromCart(MenuItem item) {
    final existingIndex = state.indexWhere((element) => element.menuItem.id == item.id);
    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      if (existingItem.quantity > 1) {
        state = [
          ...state.sublist(0, existingIndex),
          existingItem.copyWith(quantity: existingItem.quantity - 1),
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        state = [
          ...state.sublist(0, existingIndex),
          ...state.sublist(existingIndex + 1),
        ];
      }
    }
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.totalPrice);
});

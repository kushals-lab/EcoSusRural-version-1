import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addToCart(ProductModel product, {int quantity = 1}) {
    final items = List<CartItem>.from(state.items);
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }

    state = state.copyWith(items: items);
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
      state = state.copyWith(items: items);
    }
  }

  void clearCart() {
    state = const CartState();
  }

  Future<bool> processPayment() async {
    state = state.copyWith(isProcessing: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isProcessing: false);
    return true;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
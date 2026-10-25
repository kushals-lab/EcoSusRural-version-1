import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this.owner) : super(const CartState()) { ready = _restore(); }

  final String owner;
  late final Future<void> ready;
  bool _changedSinceCreation = false;
  Future<void> _writeTail = Future.value();
  String get _key => 'ecosus.cart.v1.$owner';
  Future<void> flush() => _writeTail;

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final decoded = jsonDecode(raw) as List;
      final items = <CartItem>[];
      for (final value in decoded) {
        final row = Map<String, dynamic>.from(value as Map);
        final quantity = (row['quantity'] as num?)?.toInt() ?? 0;
        if (quantity < 1) continue;
        final product = ProductModel.fromCartSnapshot(
          Map<String, dynamic>.from(row['product'] as Map));
        items.add(CartItem(product: product, quantity: quantity));
      }
      if (mounted && !_changedSinceCreation) state = state.copyWith(items: items);
    } catch (_) {
      // Corrupt cart data cannot crash the marketplace. Leave it untouched.
    }
  }

  void _save() {
    _changedSinceCreation = true;
    final snapshot = jsonEncode(state.items.map((item) => {
      'product': item.product.toCartSnapshot(), 'quantity': item.quantity,
    }).toList());
    _writeTail = _writeTail.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, snapshot);
    }).catchError((Object _) {});
  }

  void addToCart(ProductModel product, {int quantity = 1}) {
    if (quantity < 1) return;
    final items = List<CartItem>.from(state.items);
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      items[existingIndex] = CartItem(
        product: items[existingIndex].product,
        quantity: items[existingIndex].quantity + quantity);
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }

    state = state.copyWith(items: items);
    _save();
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
    _save();
  }

  void updateQuantity(String productId, int quantity) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = CartItem(product: items[index].product, quantity: quantity);
      }
      state = state.copyWith(items: items);
      _save();
    }
  }

  void clearCart() {
    state = const CartState();
    _save();
  }

  Future<bool> processPayment() async {
    state = state.copyWith(isProcessing: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isProcessing: false);
    return true;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(ref.watch(authProvider.select((state) => state.user?.uid)) ?? 'guest'),
);

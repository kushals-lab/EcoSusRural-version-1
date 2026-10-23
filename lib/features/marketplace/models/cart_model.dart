import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.priceInr * quantity;

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': quantity,
      };
}

class CartState {
  final List<CartItem> items;
  final bool isProcessing;

  const CartState({this.items = const [], this.isProcessing = false});

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get platformFee => subtotal * 0.03;

  double get deliveryCharge => subtotal > 1000 ? 0 : 95;

  double get ruralLogisticsFee => 30;

  double get gst => (subtotal + platformFee + deliveryCharge) * 0.10;

  double get total => subtotal + platformFee + deliveryCharge + ruralLogisticsFee + gst;

  CartState copyWith({
    List<CartItem>? items,
    bool? isProcessing,
  }) {
    return CartState(
      items: items ?? this.items,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
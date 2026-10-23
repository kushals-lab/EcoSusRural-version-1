import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../payment/presentation/checkout_screen.dart';
import '../models/cart_model.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    const primaryGreen = Color(0xFF1B4D3E);

    if (cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text('My Cart / मेरी टोकरी',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryGreen)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80.r, color: Colors.grey.shade400),
              SizedBox(height: 16.h),
              Text('Your cart is empty', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])),
              SizedBox(height: 8.h),
              Text('Discover authentic rural products',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('My Cart (${cart.itemCount}) / मेरी टोकरी',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryGreen)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _CartItemCard(
                  item: item,
                  onIncrease: () =>
                      cartNotifier.updateQuantity(item.product.id, item.quantity + 1),
                  onDecrease: () =>
                      cartNotifier.updateQuantity(item.product.id, item.quantity - 1),
                  onRemove: () => cartNotifier.removeFromCart(item.product.id),
                );
              },
            ),
          ),
          _buildSummary(context, cart, primaryGreen),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartState cart, Color primaryGreen) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _costRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(0)}'),
          _costRow('Platform Fee (3%)', '₹${cart.platformFee.toStringAsFixed(0)}'),
          _costRow('Delivery', cart.deliveryCharge == 0 ? 'FREE' : '₹${cart.deliveryCharge.toStringAsFixed(0)}'),
          _costRow('Rural Logistics', '₹${cart.ruralLogisticsFee.toStringAsFixed(0)}'),
          _costRow('GST (10%)', '₹${cart.gst.toStringAsFixed(0)}'),
          const Divider(height: 16),
          _costRow('Total', '₹${cart.total.toStringAsFixed(0)}', isBold: true),
          SizedBox(height: 12.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            child: Text('Proceed to Checkout / चेकआउट करें',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: isBold ? const Color(0xFF1B4D3E) : Colors.black87)),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final dynamic item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.shopping_bag, color: _primaryGreen, size: 30.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Text('₹${item.product.priceInr.toStringAsFixed(0)} each',
                    style: TextStyle(fontSize: 13.sp, color: _primaryGreen)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: onDecrease,
                            padding: EdgeInsets.all(4.r),
                            constraints: const BoxConstraints(),
                          ),
                          Text('${item.quantity}',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: onIncrease,
                            padding: EdgeInsets.all(4.r),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text('₹${item.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.grey[500]),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
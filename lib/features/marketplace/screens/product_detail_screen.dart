import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../../payment/presentation/checkout_screen.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.product});
  final ProductModel product;
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  /// Localised label for the Buy Now button — shown in the user's selected
  /// language only (not hard-coded bilingual any more).
  String get _buyNowLabel => 'buyNow';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          product.title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image Placeholder
            Container(
              height: 240.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _categoryColor(product.category).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Icon(_categoryIcon(product.category), size: 90.r, color: _categoryColor(product.category)),
              ),
            ),
            SizedBox(height: 16.h),

            // Title & Price
            Text(product.title, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text('₹${product.priceInr.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                SizedBox(width: 12.w),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    SizedBox(width: 4.w),
                    Text('${product.rating} (${product.reviewCount} reviews)',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Certification Badges
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: product.badges.map((badge) => _FullBadgeChip(badge: badge)).toList(),
            ),

            SizedBox(height: 20.h),

            // Description
            Text('Description', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 8.h),
            Text(product.description, style: TextStyle(fontSize: 14.sp, color: Colors.grey[800], height: 1.6)),

            SizedBox(height: 20.h),

            // Maker Profile Card
            _MakerProfileCard(product: product),

            SizedBox(height: 20.h),

            // Impact Story
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Color(0xFF2E7D32), size: 20),
                      SizedBox(width: 8.w),
                      Text('Impact Story', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B4D3E))),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(product.impactStory, style: TextStyle(fontSize: 13.sp, color: Colors.grey[800], height: 1.5)),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Add to Cart / Buy Now buttons
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryGreen,
                      side: const BorderSide(color: Color(0xFF1B4D3E), width: 1.5),
                      minimumSize: Size(double.infinity, 54.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      ref.read(cartProvider.notifier).addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Added to cart! / टोकरी में जोड़ा गया!'),
                          action: SnackBarAction(
                            label: 'View Cart',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CartScreen()),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: Text('Add to Cart', style: TextStyle(color: _primaryGreen, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      minimumSize: Size(double.infinity, 54.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      ref.read(cartProvider.notifier).addToCart(product);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                      );
                    },
                    child: Text(ref.tr(_buyNowLabel), style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'Handlooms':
        return Icons.checkroom;
      case 'Handicrafts':
        return Icons.palette;
      case 'Pottery & Ceramics':
        return Icons.cookie;
      case 'Organic Produce':
        return Icons.eco;
      case 'Spices':
        return Icons.local_florist;
      case 'Processed Foods':
        return Icons.restaurant;
      default:
        return Icons.shopping_bag;
    }
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Handlooms':
        return const Color(0xFF7B1FA2);
      case 'Handicrafts':
        return const Color(0xFF1565C0);
      case 'Pottery & Ceramics':
        return const Color(0xFFD84315);
      case 'Organic Produce':
        return const Color(0xFF2E7D32);
      case 'Spices':
        return const Color(0xFFB71C1C);
      case 'Processed Foods':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF455A64);
    }
  }
}

class _MakerProfileCard extends StatelessWidget {
  const _MakerProfileCard({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: const Color(0xFF1B4D3E).withValues(alpha: 0.15),
            child: const Icon(Icons.person, color: Color(0xFF1B4D3E), size: 30),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.makerName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Colors.black87)),
                SizedBox(height: 2.h),
                Text('${product.makerVillage}, ${product.state}',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
                SizedBox(height: 4.h),
                const Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text('Government Verified Seller', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullBadgeChip extends StatelessWidget {
  const _FullBadgeChip({required this.badge});
  final CertificationBadge badge;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (badge) {
      CertificationBadge.giCertified => ('GI Certified', const Color(0xFFB8860B), Icons.emoji_events),
      CertificationBadge.sustainabilityVerified => ('Eco Verified', const Color(0xFF2E7D32), Icons.eco),
      CertificationBadge.handicraftVerified => ('Handicraft Verified', const Color(0xFF1565C0), Icons.handyman),
      CertificationBadge.organicCertified => ('Organic Certified', const Color(0xFF558B2F), Icons.local_florist),
      CertificationBadge.labTested => ('Lab Tested', const Color(0xFF6A1B9A), Icons.science),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

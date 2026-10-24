import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'success_stories_hub_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  List<ProductModel> _products = kSampleProducts;
  String _catalogStatus = 'Example catalog - prices and availability are not live';
  @override void initState() { super.initState(); _loadCatalog(); }
  Future<void> _loadCatalog() async {
    try {
      final data = await DependencyInjection.apiClient.get('/products');
      final products = (data['records'] as List).map((j) => ProductModel(
        id: j['id'].toString(), title: j['title'].toString(), description: '',
        priceInr: double.parse(j['price'].toString()), category: j['category'] ?? '',
        state: '', makerName: '', makerVillage: '', rating: 0)).toList();
      if (mounted) {
        setState(() {
        _products = products;
        _catalogStatus = '${data['_isCache'] == true ? 'Cached catalog - not live' : 'Retrieved catalog'}\nUpdated: ${data['last_fetched_at']}';
      });
      }
    } catch (_) { /* Explicitly labelled example catalogue remains available. */ }
  }
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.makerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.state.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(networkStatusProvider, (previous, next) { if (next.isOnline && previous?.isOnline != true) _loadCatalog(); });
    final products = _filteredProducts;
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          ref.tr('marketplace'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${cart.itemCount}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(8), child: Text(_catalogStatus)),
          // Search Bar + Voice Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: ref.tr('searchMarketplace'),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1B4D3E)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice search listening in your language...')),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: _primaryGreen,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.mic, color: Colors.white, size: 22.r),
                  ),
                ),
              ],
            ),
          ),

          // Category Filter Chips
          SizedBox(
            height: 38.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: ['All', ...kProductCategories].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(category == 'All' ? ref.tr('allCategories') : category),
                    selected: isSelected,
                    selectedColor: _primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12.sp,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = category),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 6.h),

          // Product Grid
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No products found for this filter.'))
                : GridView.builder(
                    padding: EdgeInsets.all(16.r),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      // Height follows the card width (as childAspectRatio did)
                      // and grows with the user's text-scale setting so the
                      // card contents never overflow.
                      mainAxisExtent: (247.w * MediaQuery.textScalerOf(context).scale(1.0)).toDouble(),
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(product: product);
                    },
                  ),
          ),

          // Success Stories Showcase Banner (Section 3.1.3)
          // Tap → "Stories & Videos" section (watch), upload icon → the
          // "Upload Video" section of the same hub.
          InkWell(
            onTap: () => _openSuccessStoriesHub(context),
            child: Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.tr('successStories'),
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.brown.shade800),
                        ),
                        Text(
                          'Watch video interviews · Upload your own video',
                          style: TextStyle(fontSize: 10.sp, color: Colors.brown.shade700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Upload video',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _openSuccessStoriesHub(context, initialTabIndex: 1),
                    icon: Icon(Icons.cloud_upload_outlined, color: Colors.brown.shade800, size: 20),
                  ),
                  Icon(Icons.chevron_right, color: Colors.brown.shade800, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Success Stories & Interviews hub — section 1 lets anyone watch published
  /// interviews, section 2 lets anyone upload their own video.
  void _openSuccessStoriesHub(BuildContext context, {int initialTabIndex = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessStoriesHubScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final ProductModel product;
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _categoryColor(product.category).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                ),
                child: Center(
                  child: Icon(_categoryIcon(product.category), size: 40.r, color: _categoryColor(product.category)),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        product.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Flexible(
                      child: Text(
                        '₹${product.priceInr.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: _primaryGreen),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 13),
                          SizedBox(width: 3.w),
                          Flexible(
                            child: Text(
                              '${product.rating} (${product.reviewCount})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Single-row chip strip: the previous Wrap folded onto a
                    // second row on 390x844-class screens and overflowed the
                    // fixed-height card by ~5px (debug stripe).
                    SizedBox(
                      height: 26.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        itemCount: product.isBiodegradable
                            ? product.badges.take(3).length + 1
                            : product.badges.take(3).length,
                        separatorBuilder: (_, __) => SizedBox(width: 3.w),
                        itemBuilder: (context, index) {
                          if (product.isBiodegradable) {
                            if (index == 0) return const _BiodegradableChip();
                            return _BadgeChip(
                                badge: product.badges[index - 1]);
                          }
                          return _BadgeChip(badge: product.badges[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
      case 'Biodegradable':
        return Icons.recycling;
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
      case 'Biodegradable':
        return const Color(0xFF558B2F);
      default:
        return const Color(0xFF455A64);
    }
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.badge});
  final CertificationBadge badge;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (badge) {
      CertificationBadge.giCertified => ('GI Certified', const Color(0xFFB8860B)),
      CertificationBadge.sustainabilityVerified => ('Eco Verified', const Color(0xFF2E7D32)),
      CertificationBadge.handicraftVerified => ('Handicraft', const Color(0xFF1565C0)),
      CertificationBadge.organicCertified => ('Organic', const Color(0xFF558B2F)),
      CertificationBadge.labTested => ('Lab Tested', const Color(0xFF6A1B9A)),
    };

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(label),
            content: Text(
              'Government Verified Badge: Verified against National Registry and accredited laboratory test certificates.',
              style: TextStyle(fontSize: 13.sp),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 8.sp, color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _BiodegradableChip extends StatelessWidget {
  const _BiodegradableChip();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF558B2F);
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Biodegradable'),
            content: Text(
              'Verified compostable / plastic-free product. GI tag is NOT '
              'required — any biodegradable product qualifies for this '
              'section of the marketplace.',
              style: TextStyle(fontSize: 13.sp),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close')),
            ],
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recycling, size: 9.r, color: color),
            SizedBox(width: 2.w),
            Text('Biodegradable',
                style: TextStyle(
                    fontSize: 8.sp, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

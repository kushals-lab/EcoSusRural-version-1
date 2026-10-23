import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/language_provider.dart';
import '../../language/screens/language_gateway_screen.dart';
import '../../learning/screens/learning_academy_screen.dart';
import '../../marketplace/models/product_model.dart';
import '../../marketplace/screens/product_detail_screen.dart';
import '../../marketplace/screens/success_stories_hub_screen.dart';
import '../../payments/screens/wallet_screen.dart';
import '../../profile/providers/farmer_profile_provider.dart';
import '../../schemes/screens/my_applications_screen.dart';
import '../../schemes/screens/schemes_screen.dart';
import '../../settings/screens/help_support_screen.dart';
import '../../legal/screens/legal_agreement_screen.dart';
import '../screens/export_global_market_screen.dart';
import '../screens/seller_registration_screen.dart';

class SellerDashboardScreen extends ConsumerStatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  ConsumerState<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends ConsumerState<SellerDashboardScreen> {
  int _currentTab = 0;
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(farmerProfileProvider);
    final String farmerName = profile.name.isNotEmpty ? profile.name : 'Kisan (Farmer)';

    final tabs = [
      _buildOverview(farmerName),
      _buildProducts(),
      _buildOrders(),
      _buildAnalytics(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          ref.tr('sellerDashboard'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: tabs[_currentTab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) => setState(() => _currentTab = index),
        indicatorColor: _primaryGreen.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildOverview(String farmerName) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B4D3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: Colors.white, size: 36),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmerName,
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4.h),
                      const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.lightBlueAccent, size: 16),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Govt Verified - Bank Verified',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          _buildUpgradeToSeller(context),
          SizedBox(height: 20.h),

          Text('Sales Overview', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
          SizedBox(height: 12.h),
          _buildSalesStats(),
          SizedBox(height: 20.h),

          Text('Account and Tools', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
          SizedBox(height: 12.h),
          _buildMenuItems(),
        ],
      ),
    );
  }

  Widget _buildUpgradeToSeller(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront, color: Colors.amber.shade700, size: 24),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Upgrade to Seller Account',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Sell your products to buyers across India and globally. Get access to a seller dashboard, '
            'fair pricing, logistics support, and financial tools.',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.5),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SellerRegistrationScreen(),
                ),
              );
            },
            child: Text('Become a Seller',
                style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesStats() {
    final stats = [
      ('Today', 'Rs 2,450', Icons.today, Colors.blue),
      ('This Week', 'Rs 18,750', Icons.date_range, Colors.green),
      ('This Month', 'Rs 78,420', Icons.calendar_month, Colors.orange),
      ('Net Payout', 'Rs 70,540', Icons.account_balance_wallet, Colors.purple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // Cell height follows the card width (as childAspectRatio did) and
        // grows with the user's text-scale setting so the stats never overflow.
        mainAxisExtent: (108.w * MediaQuery.textScalerOf(context).scale(1.0)).toDouble(),
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(stat.$3, color: stat.$4, size: 18),
                  const Spacer(),
                  Icon(Icons.trending_up, color: stat.$4, size: 16),
                ],
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                    Text(stat.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems() {
    // Every row routes to a page that already exists in the app — no new
    // features, just wiring that was previously `onTap: () {}`.
    final items = <(String, IconData, void Function(BuildContext))>[
      ('My Products', Icons.inventory_2, (ctx) => setState(() => _currentTab = 1)),
      ('My Orders', Icons.receipt_long, (ctx) => setState(() => _currentTab = 2)),
      ('Payouts', Icons.payments, _openPayouts),
      ('Financial Reports', Icons.insights, (ctx) => setState(() => _currentTab = 3)),
      ('Training Academy', Icons.school, _openTrainingAcademy),
      ('Export / Global Market', Icons.public, _openExportMarket),
      ('Success Stories & Interviews', Icons.video_library, _openSuccessStories),
      ('Language Settings', Icons.language, _openLanguageSettings),
      ('Schemes, Loan and Insurance', Icons.account_balance, _openSchemes),
      ('My Applications', Icons.description, _openMyApplications),
      ('Terms & Conditions', Icons.policy_outlined, _openTermsPrivacy),
      ('Help and Support', Icons.support_agent, _openHelpSupport),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          return Column(
            children: [
              Material(
                color: Colors.white,
                child: ListTile(
                  leading: Icon(item.$2, color: _primaryGreen),
                  title: Text(item.$1, style: TextStyle(fontSize: 14.sp)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => item.$3(context),
                ),
              ),
              if (entry.key < items.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _openPayouts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalletScreen()),
    );
  }

  void _openTrainingAcademy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LearningAcademyScreen()),
    );
  }

  void _openExportMarket(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExportGlobalMarketScreen()),
    );
  }

  void _openSuccessStories(BuildContext context) {
    // Success Stories & Interviews hub: section 1 lets anyone watch published
    // interviews, section 2 lets anyone upload their own video.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuccessStoriesHubScreen()),
    );
  }

  void _openLanguageSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const LanguageGatewayScreen(popAfterSelect: true)),
    );
  }

  void _openSchemes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SchemesScreen()),
    );
  }

  void _openMyApplications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
    );
  }

  void _openTermsPrivacy(BuildContext context) {
    // Re-read mode: returns to the seller menu instead of login/registration.
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const LegalAgreementScreen(isReadOnly: true)),
    );
  }

  void _openHelpSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  void _openProductDetail(BuildContext context, (String, String, String, String, int, double) product) {
    // Maps the demo seller-catalogue tuple onto the existing marketplace
    // ProductModel so we reuse ProductDetailScreen (no new feature).
    final match = kSampleProducts.where((p) => p.title == product.$1).firstOrNull;
    final resolved = match ??
        ProductModel(
          id: 'seller-${product.$1.hashCode.abs()}',
          title: product.$1,
          description: '${product.$1} — ${product.$2}. Listed by you on EcoSusRural.',
          priceInr: _parseRs(product.$3),
          category: product.$2,
          state: '',
          makerName: 'You',
          makerVillage: '',
          rating: product.$6,
          reviewCount: product.$5,
        );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: resolved)),
    );
  }

  double _parseRs(String label) {
    final digits = label.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0;
  }

  Widget _buildProducts() {
    final products = [
      ('Banarasi Silk Saree', 'Handlooms', 'Rs 12,500', 'In Stock', 128, 4.9),
      ('Organic A2 Ghee', 'Organic Produce', 'Rs 1,850', 'In Stock', 342, 4.8),
      ('Chikankari Kurta', 'Handicrafts', 'Rs 2,450', 'Low Stock', 96, 4.7),
      ('Naga Chilli Pickle', 'Processed Foods', 'Rs 425', 'In Stock', 210, 4.6),
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: products.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {
                // Demo catalogue drill-down (existing page): preview the
                // first listed product instead of a dead button.
                _openProductDetail(context, products[0]);
              },
              icon: const Icon(Icons.add),
              label: Text('Add New Product',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
            ),
          );
        }
        final product = products[index - 1];
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: _primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Icons.shopping_bag, color: _primaryGreen, size: 26),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.$1, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    Text('${product.$2} - ${product.$3}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: (product.$4 == 'In Stock' ? Colors.green : Colors.orange).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(product.$4,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: product.$4 == 'In Stock' ? Colors.green.shade700 : Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        SizedBox(width: 8.w),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(' ${product.$6} (${product.$5})',
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrders() {
    final orders = [
      ('ORD-2026-001', 'Banarasi Silk Saree', 'Rs 12,500', 'Pending', 'Priya Sharma, Mumbai'),
      ('ORD-2026-002', 'Organic A2 Ghee x2', 'Rs 3,700', 'Shipped', 'Rahul Mehta, Delhi'),
      ('ORD-2026-003', 'Chikankari Kurta', 'Rs 2,450', 'Delivered', 'Ananya Iyer, Bengaluru'),
      ('ORD-2026-004', 'Naga Chilli Pickle x3', 'Rs 1,275', 'Processing', 'Vikram Singh, Pune'),
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final statusColor = switch (order.$4) {
          'Pending' => Colors.orange,
          'Shipped' => Colors.blue,
          'Delivered' => Colors.green,
          'Processing' => Colors.purple,
          _ => Colors.grey,
        };

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(order.$1, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(order.$4,
                        style: TextStyle(fontSize: 10.sp, color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(order.$2, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              Text('${order.$3} - ${order.$5}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              SizedBox(height: 8.h),
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryGreen,
                      side: const BorderSide(color: Color(0xFF1B4D3E)),
                      minimumSize: Size(0, 36.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () {},
                    child: Text('Update Status', style: TextStyle(fontSize: 12.sp)),
                  ),
                  SizedBox(width: 8.w),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      minimumSize: Size(0, 36.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () {},
                    child: Text('Reject', style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenue Trend (Last 6 Months)',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                SizedBox(height: 16.h),
                Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: _primaryGreen.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Center(
                    child: Icon(Icons.bar_chart, size: 48, color: Color(0xFF1B4D3E)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),
          Text('Financial Intelligence', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
          SizedBox(height: 12.h),

          _metricCard('Total Revenue (YTD)', 'Rs 8,42,500', Icons.currency_rupee, Colors.green),
          _metricCard('Total Orders', '1,247', Icons.receipt_long, Colors.blue),
          _metricCard('Average Order Value', 'Rs 675', Icons.shopping_cart, Colors.orange),
          _metricCard('Net Payouts', 'Rs 7,58,250', Icons.account_balance_wallet, Colors.purple),

          SizedBox(height: 16.h),
          Text('Top Performing Products', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
          SizedBox(height: 12.h),

          _topProductRow('1', 'Banarasi Silk Saree', 'Rs 4,12,500', 'Up 12%'),
          _topProductRow('2', 'Organic A2 Ghee', 'Rs 2,85,000', 'Up 8%'),
          _topProductRow('3', 'Chikankari Kurta', 'Rs 1,92,000', 'Flat 3%'),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topProductRow(String rank, String name, String revenue, String trend) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(rank, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: _primaryGreen))),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          ),
          Text(revenue, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
          SizedBox(width: 8.w),
          Text(trend, style: TextStyle(fontSize: 12.sp, color: Colors.green.shade700)),
        ],
      ),
    );
  }
}
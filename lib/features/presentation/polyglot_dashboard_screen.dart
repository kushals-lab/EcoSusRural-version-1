import '../auth/providers/display_name_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../seller/screens/seller_dashboard_screen.dart';
import '../marketplace/screens/marketplace_screen.dart';
import '../schemes/screens/schemes_screen.dart';
import '../weather/screens/weather_screen.dart';
import '../learning/screens/learning_academy_screen.dart';
import '../circular_economy/screens/circular_economy_screen.dart';
import '../language/screens/language_gateway_screen.dart';
import '../settings/screens/settings_screen.dart';



class PolyglotDashboardScreen extends ConsumerStatefulWidget {
  const PolyglotDashboardScreen({super.key});
  @override
  ConsumerState<PolyglotDashboardScreen> createState() => _PolyglotDashboardScreenState();
}

class _PolyglotDashboardScreenState extends ConsumerState<PolyglotDashboardScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);
  int _selectedSection = 0;
  final List<String> _sections = ['Home','Marketplace','Schemes & Loans','Learning','Weather','Circular Economy','Settings'];
  final List<String> _sellerSections = ['My Products','My Orders','Seller Analytics'];
  final List<_QA> _allUserActions = [
    const _QA(Icons.storefront, 'Marketplace', Color(0xFF1565C0), 'marketplace'),
    const _QA(Icons.account_balance, 'Govt Schemes & Loans', Color(0xFF2E7D32), 'schemes'),
    const _QA(Icons.school, 'Learning & Skilling', Color(0xFF7B1FA2), 'learning'),
    const _QA(Icons.cloud, 'Weather & Crop Advisory', Color(0xFF00796B), 'weather'),
    const _QA(Icons.recycling, 'Circular Economy', Color(0xFF558B2F), 'circular_economy'),
    const _QA(Icons.language, 'Language Settings', Color(0xFF455A64), 'language'),
    const _QA(Icons.settings, 'Settings', Color(0xFF455A64), 'settings'),
  ];
  final List<_QA> _sellerActions = [
    const _QA(Icons.inventory_2, 'My Products', Color(0xFF1565C0), 'my_products'),
    const _QA(Icons.receipt_long, 'My Orders', Color(0xFF2E7D32), 'my_orders'),
    const _QA(Icons.analytics, 'Seller Analytics & Dashboard', Color(0xFF455A64), 'seller_analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: _primaryGreen),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Namaste ${ref.watch(displayNameProvider).valueOrNull ?? ''}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            Text('EcoSusRural', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]))
          ]
        ),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), color: _primaryGreen, onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No new notifications')))),
          IconButton(icon: const Icon(Icons.person_outline), color: _primaryGreen, onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile'))))
        ]
      ),
      body: _buildBody(false),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 1.h, color: Colors.grey.shade200),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(child: _bottomNavItem(Icons.home, 'Home', 0)),
                    Expanded(child: _bottomNavItem(Icons.storefront, 'Market', 1)),
                    Expanded(child: _bottomNavItem(Icons.school, 'Learn', 2)),
                    Expanded(child: _bottomNavItem(Icons.person, 'Profile', 3))
                  ]
                )
              )
            ]
          )
        )
      ),
    );
  }

  Widget _buildBody(bool isSeller) {
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 80.h, child: ListView.builder(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 12.w), itemCount: _sections.length + (_sellerSections.length), itemBuilder: (context, index) {
        final isSellerSection = index >= _sections.length;
        final idx = isSellerSection ? index - _sections.length : index;
        final label = isSellerSection ? _sellerSections[idx] : _sections[idx];
        final isSelected = _selectedSection == (isSellerSection ? idx : index);
        return Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: ChoiceChip(label: Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87)), selected: isSelected, selectedColor: _primaryGreen, backgroundColor: Colors.grey.shade200, onSelected: (selected) { if (selected) setState(() => _selectedSection = isSellerSection ? idx : index); }));
      })),
      SizedBox(height: 12.h),
      if (isSeller) ...[Text('Seller Quick Actions', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)), SizedBox(height: 8.h), _buildQuickActionGrid(_sellerActions), SizedBox(height: 16.h)],
      Text('Quick Access', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
      SizedBox(height: 8.h),
      _buildQuickActionGrid(_allUserActions),
      SizedBox(height: 16.h),
      Text('Explore', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
      SizedBox(height: 8.h),
      _buildExploreGrid(isSeller),
      SizedBox(height: 24.h),
    ]));
  }

  Widget _buildQuickActionGrid(List<_QA> actions) {
    return Wrap(spacing: 10.w, runSpacing: 10.h, children: actions.map((a) => InkWell(onTap: () => _navigateTo(a.screen), borderRadius: BorderRadius.circular(12.r), child: Container(padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.h), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)]), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(color: a.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)), child: Icon(a.icon, color: a.color, size: 20)), SizedBox(width: 8.w), Flexible(child: Text(a.label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87)))])))).toList());
  }

  Widget _buildExploreGrid(bool isSeller) {
    final items = <_EI>[
      const _EI(Icons.storefront, 'Marketplace', 'Buy authentic rural products', Color(0xFF1565C0), 'marketplace'),
      const _EI(Icons.account_balance, 'Rural Development Schemes & Loans', 'Govt loans, insurance, scholarships', Color(0xFF2E7D32), 'schemes'),
      const _EI(Icons.school, 'Learning & Skilling Academy', 'Courses for farmers & artisans', Color(0xFF7B1FA2), 'learning'),
      if (isSeller) const _EI(Icons.inventory_2, 'My Products', 'Manage your product listings', Color(0xFF1565C0), 'my_products'),
      if (isSeller) const _EI(Icons.receipt_long, 'My Orders', 'Track buyer orders', Color(0xFF2E7D32), 'my_orders'),
      const _EI(Icons.cloud, 'Weather & Crop Advisory', 'Weather data', Color(0xFF00796B), 'weather'),
      const _EI(Icons.recycling, 'Circular Economy', 'Recycling & waste management', Color(0xFF558B2F), 'circular_economy'),
      const _EI(Icons.language, 'Language Settings', 'Change app language', Color(0xFF455A64), 'language'),
      const _EI(Icons.settings, 'Settings', 'App preferences', Color(0xFF455A64), 'settings'),
    ];
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10.h, crossAxisSpacing: 10.h, mainAxisExtent: (172.w * MediaQuery.textScalerOf(context).scale(1.0)).toDouble()), itemCount: items.length, itemBuilder: (context, index) { final item = items[index]; return _FC(icon: item.icon, title: item.title, subtitle: item.subtitle, color: item.color, onTap: () => _navigateTo(item.screen)); });
  }

  Widget _bottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedSection == index;
    return GestureDetector(onTap: () { setState(() => _selectedSection = index); _navigateTo(_getScreenForBottomNav(index)); }, child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(color: isSelected ? _primaryGreen.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8.r)), child: Icon(icon, color: isSelected ? _primaryGreen : Colors.grey[600], size: 22)), SizedBox(height: 2.h), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? _primaryGreen : Colors.grey[600]))]));
  }

  String _getScreenForBottomNav(int index) { switch (index) { case 0: return 'home'; case 1: return 'marketplace'; case 2: return 'learning'; case 3: return 'settings'; default: return 'home'; } }

  void _navigateTo(String screenId) {
    switch (screenId) {
      case 'marketplace': Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())); break;
      case 'schemes': Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemesScreen())); break;
      case 'learning': Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningAcademyScreen())); break;
      case 'weather': Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())); break;
      case 'circular_economy': Navigator.push(context, MaterialPageRoute(builder: (_) => const CircularEconomyScreen())); break;
      case 'language': Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageGatewayScreen(popAfterSelect: true))); break;
      case 'settings': Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); break;
      case 'my_products': Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerDashboardScreen())); break;
      case 'my_orders': Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerDashboardScreen())); break;
      default: break;
    }
  }
}

class _QA { final IconData icon; final String label; final Color color; final String screen; const _QA(this.icon, this.label, this.color, this.screen); }
class _EI { final IconData icon; final String title; final String subtitle; final Color color; final String screen; const _EI(this.icon, this.title, this.subtitle, this.color, this.screen); }

class _FC extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  const _FC({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12.r), child: Container(padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)]), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)), child: Icon(icon, color: color, size: 24)),
      SizedBox(height: 8.h),
      Flexible(child: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)),
      SizedBox(height: 2.h),
      Flexible(child: Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
    ])));
  }
}

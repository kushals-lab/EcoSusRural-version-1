import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../../profile/providers/farmer_profile_provider.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../rural_ai/screens/rural_intelligence_screen.dart';
import '../../marketplace/screens/marketplace_screen.dart';
import '../../marketplace/screens/farmer_processing_hub_screen.dart';
import '../../marketplace/screens/artisan_export_hub_screen.dart';
import '../../schemes/screens/schemes_screen.dart';
import '../../schemes/screens/msp_support_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../learning/screens/learning_academy_screen.dart';
import '../../seller/screens/seller_dashboard_screen.dart';
import '../../competitions/screens/competitions_screen.dart';
import '../../expert_advice/screens/expert_advice_screen.dart';
import '../../village_outreach/screens/village_outreach_screen.dart';
import '../../circular_economy/screens/circular_economy_screen.dart';
import '../../reviews/screens/reviews_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../legal/screens/ethics_integrity_pledge_screen.dart';
import '../../smart_dryer/screens/smart_dryer_screen.dart';

class MainDashboardScreen extends ConsumerStatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  ConsumerState<MainDashboardScreen> createState() =>
      _MainDashboardScreenState();
}

class _MainDashboardScreenState extends ConsumerState<MainDashboardScreen> {
  int _currentIndex = 0;
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  // Tab shells are built once and cached: switching tabs then only swaps the
  // visible child instead of rebuilding all five screens on every frame.
  // The home tab depends on the farmer name/crop, so it is keyed by them.
  // RuralIntelligenceScreen is the rightmost AI tab. AiAssistantScreen remains
  // available via the follow-up chat button on the Rural Intelligence screen.
  final Map<String, Widget> _pageCache = {};
  static const List<Widget> _staticTabs = [
    MarketplaceScreen(),
    LearningAcademyScreen(),
    SellerDashboardScreen(),
    RuralIntelligenceScreen(),
  ];

  Widget _homeTab(String farmerName, String mainCrop) {
    final key = '$farmerName|$mainCrop';
    return _pageCache.putIfAbsent(
        'home|$key', () => _buildHomeTab(farmerName, mainCrop));
  }

  @override
  Widget build(BuildContext context) {
    // Watch only the two derived values the dashboard renders, so unrelated
    // profile state changes (isSubmitting, errorMessage, …) never rebuild
    // the whole shell. Records compare structurally in Riverpod's select.
    final (String farmerName, String mainCrop) = ref.watch(
      farmerProfileProvider.select((s) {
        final name = s.name.isNotEmpty ? s.name : 'Kisan';
        final crop = s.selectedCrops.isNotEmpty
            ? s.selectedCrops.first.split(' / ')[0]
            : 'Crops';
        return (name, crop);
      }),
    );

    final pages = [
      _homeTab(farmerName, mainCrop),
      _staticTabs[0],
      _staticTabs[1],
      _staticTabs[2],
      _staticTabs[3],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      // IndexedStack keeps tab state alive and swaps visibility instead of
      // rebuilding the active screen on every navigation tap.
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: _primaryGreen.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: ref.tr('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: ref.tr('market'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            label: ref.tr('learn'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: ref.tr('seller'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.smart_toy_outlined),
            selectedIcon: const Icon(Icons.smart_toy),
            label: ref.tr('aiGuide'),
          ),
        ],
      ),
    );
  }

  // ==================== HOME TAB ====================
  Widget _buildHomeTab(String farmerName, String mainCrop) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${ref.tr('greetingPrefix')}, $farmerName',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen),
            ),
            Text(
              ref.tr('farmLookingGood'),
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: _primaryGreen),
            tooltip: ref.tr('ethicsPledge'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const EthicsIntegrityPledgeScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            tooltip: ref.tr('settings'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()));
            },
          ),
          SizedBox(width: 6.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWeatherCard(),
                SizedBox(height: 20.h),
                Text(
                  ref.tr('exploreModules'),
                  style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen),
                ),
                SizedBox(height: 12.h),
                _buildModuleGrid(),
                SizedBox(height: 20.h),
                Text(
                  ref.tr('quickActions'),
                  style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen),
                ),
                SizedBox(height: 10.h),
                _buildQuickActions(),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ref.tr('recommendedMasterclasses'),
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      ref.tr('viewAll'),
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildMasterclassHorizontalList(mainCrop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget: Module Grid
  Widget _buildModuleGrid() {
    final modules = [
      (
        ref.tr('marketplace'),
        Icons.storefront,
        const Color(0xFF1565C0),
        const MarketplaceScreen()
      ),
      (
        ref.tr('govtSchemes'),
        Icons.account_balance,
        const Color(0xFF2E7D32),
        const SchemesScreen()
      ),
      (
        ref.tr('mspSupport'),
        Icons.agriculture,
        const Color(0xFF558B2F),
        const MspSupportScreen()
      ),
      (
        ref.tr('farmerHub'),
        Icons.eco,
        const Color(0xFF00796B),
        const FarmerProcessingHubScreen()
      ),
      (
        ref.tr('smartDryer'),
        Icons.solar_power,
        const Color(0xFFE65100),
        const SmartDryerScreen()
      ),
      (
        ref.tr('artisanHub'),
        Icons.palette,
        const Color(0xFF6A1B9A),
        const ArtisanExportHubScreen()
      ),
      (
        ref.tr('circularEconomy'),
        Icons.recycling,
        const Color(0xFF2E7D32),
        const CircularEconomyScreen()
      ),
      (
        ref.tr('weather'),
        Icons.cloud,
        const Color(0xFF1E88E5),
        const WeatherScreen()
      ),
      (
        ref.tr('learningAcademy'),
        Icons.school,
        const Color(0xFF7B1FA2),
        const LearningAcademyScreen()
      ),
      (
        ref.tr('aiAssistant'),
        Icons.smart_toy,
        const Color(0xFFF57C00),
        const AiAssistantScreen()
      ),
      (
        ref.tr('competitions'),
        Icons.emoji_events,
        const Color(0xFFB8860B),
        const CompetitionsScreen()
      ),
      (
        ref.tr('expertAdvice'),
        Icons.support_agent,
        const Color(0xFF00695C),
        const ExpertAdviceScreen()
      ),
      (
        ref.tr('villageOutreach'),
        Icons.groups,
        const Color(0xFFD84315),
        const VillageOutreachScreen()
      ),
      (
        ref.tr('ethicsPledge'),
        Icons.verified_user,
        const Color(0xFF1B4D3E),
        const EthicsIntegrityPledgeScreen()
      ),
      (
        ref.tr('reviewsHelpdesk'),
        Icons.star,
        const Color(0xFFF57C00),
        const ReviewsScreen()
      ),
      (
        ref.tr('settings'),
        Icons.settings,
        const Color(0xFF455A64),
        const SettingsScreen()
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.92,
      children: modules.map((m) {
        return InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => m.$4));
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: m.$3.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(m.$2, color: m.$3, size: 22.r),
                ),
                SizedBox(height: 6.h),
                Text(
                  m.$1,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget: Weather Card
  Widget _buildWeatherCard() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const WeatherScreen()));
      },
      borderRadius: BorderRadius.circular(16.r),
      // Gradient + shadow layers repaint every frame during scrolling unless
      // isolated; RepaintBoundary caches this card as its own raster layer.
      child: RepaintBoundary(
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B4D3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                  color: _primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.yellow, size: 44),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear & Sunny • 28°C',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'AI Tip: Soil moisture is optimal. Delay irrigation by 2 days.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  // Widget: Quick Actions
  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16.w,
      runSpacing: 12.h,
      children: [
        _actionButton(Icons.pest_control, ref.tr('pestId'), Colors.red.shade100,
            Colors.red, () {
          setState(() => _currentIndex = 3);
        }),
        _actionButton(Icons.currency_rupee, ref.tr('marketRate'),
            Colors.green.shade100, Colors.green, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MspSupportScreen()));
        }),
        _actionButton(Icons.water_drop, ref.tr('irrigation'),
            Colors.blue.shade100, Colors.blue, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const WeatherScreen()));
        }),
        _actionButton(Icons.group, ref.tr('community'), Colors.orange.shade100,
            Colors.orange, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const VillageOutreachScreen()));
        }),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color bgColor,
      Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24.r),
          ),
          SizedBox(height: 6.h),
          Text(label,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Widget: Masterclass List
  Widget _buildMasterclassHorizontalList(String crop) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _masterclassCard(
              title: 'High Yield $crop Techniques',
              expert: 'Dr. M. S. Swaminathan Team',
              imageColor: Colors.amber.shade200,
            ),
            _masterclassCard(
              title: 'Organic Pest Control',
              expert: 'ICAR Institute',
              imageColor: Colors.lightGreen.shade200,
            ),
            _masterclassCard(
              title: 'Export Documentation & IEC',
              expert: 'DGFT / Spice Board Expert',
              imageColor: Colors.blue.shade200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _masterclassCard(
      {required String title,
      required String expert,
      required Color imageColor}) {
    return SizedBox(
      width: 210.w,
      child: Container(
        margin: EdgeInsets.only(right: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 95.h,
              decoration: BoxDecoration(
                color: imageColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_outline,
                    size: 38, color: Colors.black45),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 13, color: Colors.blue),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          expert,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 11.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

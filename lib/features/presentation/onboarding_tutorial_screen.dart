import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/permission/location_permission.dart';
import '../dashboard/screens/main_dashboard_screen.dart';

class OnboardingTutorialScreen extends ConsumerStatefulWidget {
  const OnboardingTutorialScreen({super.key});

  @override
  ConsumerState<OnboardingTutorialScreen> createState() => _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends ConsumerState<OnboardingTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  void initState() {
    super.initState();
    // The tour is the last step before the dashboard, so if the location
    // consent was never captured (for example when the Sign-up screen was
    // skipped) we ask for it here — one step before the tutorial content.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _askLocationIfNeverAsked());
  }

  Future<void> _askLocationIfNeverAsked() async {
    await LocationPermissionStore.load();
    if (!mounted) return;
    if (LocationPermissionStore.mode != LocationAccessMode.notAsked) return;
    await showLocationPermissionSheet(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHowItWorksPage(),
      _buildMissionImpactPage(),
      _buildDashboardTourPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _onFinish,
            child: Text(
              ref.tr('skip'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: pages,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 6.w),
                        width: _currentPage == i ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentPage == i ? _primaryGreen : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _onFinish();
                      }
                    },
                    child: Text(
                      _currentPage == pages.length - 1 ? ref.tr('getStarted') : ref.tr('next'),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 1: How EcoSusRural Works (Buyers & Sellers)
  Widget _buildHowItWorksPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.handshake_rounded, size: 72.r, color: _primaryGreen),
          ),
          SizedBox(height: 24.h),
          Text(
            ref.tr('howItWorks'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.verified_user, 'For Buyers: Verified GI, organic, sustainable & lab-tested heritage goods direct from artisans and farmers with escrow protection.'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.storefront, 'For Sellers: Direct national & global market access, fair margins, ₹1 penny-drop verified bank payouts, and logistics handling.'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.school, 'For Communities: Learn value-addition skills, get government scheme access, weather intelligence, and circular economy tools.'),
        ],
      ),
    );
  }

  // Slide 2: Mission & Real Impact Stats
  Widget _buildMissionImpactPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco_rounded, size: 72.r, color: Colors.amber.shade900),
          ),
          SizedBox(height: 24.h),
          Text(
            ref.tr('missionImpact'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildMetricCard('45,000+', 'Artisans & Farmers Empowered', Icons.people)),
              SizedBox(width: 12.w),
              Expanded(child: _buildMetricCard('1,200+', 'Villages Reached Across India', Icons.holiday_village)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildMetricCard('₹38 Cr+', 'Rural Livelihood Generated', Icons.currency_rupee)),
              SizedBox(width: 12.w),
              Expanded(child: _buildMetricCard('100%', 'Government & Lab Verified', Icons.verified)),
            ],
          ),
        ],
      ),
    );
  }

  // Slide 3: Dashboard Tour
  Widget _buildDashboardTourPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.explore_rounded, size: 72.r, color: Colors.blue.shade800),
          ),
          SizedBox(height: 24.h),
          Text(
            ref.tr('dashboardTour'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.home, 'Home Dashboard: Real-time satellite weather, personalized advisories, and quick action tools.'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.shopping_bag, 'Marketplace: Authentic GI-tagged arts, textiles, organic foods, and dried produce.'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.account_balance, 'Schemes & MSP: 200+ central/state schemes, live mandi price tracker & grievance resolution.'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.security, 'Platform Ethics: Military-grade DRM, zero piracy, and complete anti-counterfeiting pledge.'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryGreen, size: 22.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryGreen, size: 28.r),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

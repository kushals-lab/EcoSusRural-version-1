import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../messaging/screens/chat_list_screen.dart';
import '../payments/screens/wallet_screen.dart';
import '../ride_booking/screens/ride_booking_screen.dart';
import '../ride_booking/screens/rider_partner_screen.dart';
import '../flight_booking/screens/flight_search_screen.dart';
import '../train_booking/screens/train_search_screen.dart';
import '../health/screens/doctor_search_screen.dart';
import '../food_delivery/screens/restaurant_listing_screen.dart';
import '../education/screens/learning_hub_screen.dart';
import '../jobs/screens/jobs_screen.dart';
import '../marketplace/screens/marketplace_screen.dart';
import '../content/screens/content_hub_screen.dart';
import '../entertainment/screens/entertainment_screen.dart';
import '../smart_dryer/screens/dryer_suite_screen.dart';

class ServicesHubScreen extends ConsumerWidget {
  const ServicesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.tr;
    const Color primaryGreen = Color(0xFF1B4D3E);

    final services = [
      ServiceItem(name: 'EcoSusRural', icon: Icons.eco, color: primaryGreen, screen: const _EcoSusRuralHome()),
      ServiceItem(name: 'Messages', icon: Icons.chat_bubble, color: const Color(0xFF008069), screen: const ChatListScreen()),
      ServiceItem(name: 'EcoBharatPay', icon: Icons.account_balance_wallet, color: const Color(0xFF1A73E8), screen: const WalletScreen()),
      ServiceItem(name: tr('market'), icon: Icons.shopping_bag, color: const Color(0xFFFB6F00), screen: const MarketplaceScreen()),
      ServiceItem(name: tr('ride'), icon: Icons.motorcycle, color: const Color(0xFF0070E0), screen: const RideBookingScreen()),
      ServiceItem(name: 'Rider Partner', icon: Icons.workspace_premium, color: const Color(0xFF5E35B1), screen: const RiderPartnerScreen()),
      ServiceItem(name: 'Movies & Events', icon: Icons.local_activity, color: const Color(0xFFD81B60), screen: const EntertainmentScreen()),
      ServiceItem(name: tr('flights'), icon: Icons.flight, color: const Color(0xFF006CB5), screen: const FlightSearchScreen()),
      ServiceItem(name: tr('trains'), icon: Icons.train, color: const Color(0xFFE61A33), screen: const TrainSearchScreen()),
      ServiceItem(name: tr('health'), icon: Icons.medical_services, color: const Color(0xFF0BA570), screen: const DoctorSearchScreen()),
      ServiceItem(name: tr('food'), icon: Icons.restaurant, color: const Color(0xFFFF6B35), screen: const RestaurantListingScreen()),
      ServiceItem(name: tr('learn'), icon: Icons.school, color: const Color(0xFF7B1FA2), screen: const LearningHubScreen()),
      ServiceItem(name: 'Content', icon: Icons.movie_creation_rounded, color: const Color(0xFFE91E63), screen: const ContentHubScreen()),
      ServiceItem(name: tr('jobs'), icon: Icons.work, color: const Color(0xFF673AB7), screen: const JobsScreen()),
      ServiceItem(name: tr('smartDryer'), icon: Icons.solar_power, color: const Color(0xFFE65100), screen: const DryerSuiteScreen()),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(tr('services'), style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 20.sp)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16,
          mainAxisExtent: (121.w * MediaQuery.textScalerOf(context).scale(1.0)).toDouble(),
        ),
        itemCount: services.length,
        itemBuilder: (context, index) => ServiceTile(
          service: services[index],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => services[index].screen)),
        ),
      ),
    );
  }
}

class ServiceItem {
  final String name;
  final IconData icon;
  final Color color;
  final Widget screen;

  ServiceItem({required this.name, required this.icon, required this.color, required this.screen});
}

class ServiceTile extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onTap;

  const ServiceTile({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w, height: 56.w,
                decoration: BoxDecoration(color: service.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(service.icon, color: service.color, size: 28.sp),
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: Text(service.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcoSusRuralHome extends StatelessWidget {
  const _EcoSusRuralHome();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('EcoSusRural')), body: const Center(child: Text('Welcome')));
  }
}

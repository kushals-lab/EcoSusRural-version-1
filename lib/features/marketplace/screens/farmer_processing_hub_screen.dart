import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/language_provider.dart';
import '../../smart_dryer/screens/smart_dryer_screen.dart';
import 'dried_fruit_unit_page.dart';
import 'storage_lab_page.dart';
import 'spice_lab_page.dart';
import 'organic_input_page.dart';
import 'master_farmer_page.dart';

class FarmerProcessingHubScreen extends ConsumerWidget {
  const FarmerProcessingHubScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          ref.tr('farmerHub'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Header Banner
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B4D3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: _primaryGreen.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.agriculture_rounded, color: Colors.yellow, size: 28),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Farmer Processing & Value-Addition',
                        style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Transform raw produce into high-value exports: dried fruits, dehydrated vegetables, lab-tested spices, organic inputs, and Ayurvedic cosmetics.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.sp, height: 1.4),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Section 5.1: Fruit Farmer Support (Dried Fruits)
          _buildHubSection(
            context,
            icon: Icons.apple_rounded,
            color: Colors.orange.shade800,
            title: '5.1 Fruit Farmer Support — Dried Fruit Manufacturing',
            subtitle: 'Solar dehydration, vacuum drying, small unit setup & global exports',
            features: [
              'Solar & Vacuum Dehydration: Step-by-step guides for rural dehydration units.',
              'FSSAI, FDA, FSA & EFSA: Assisted licensing for Indian and international food safety.',
              'Global Demand Intelligence: Real-time price benchmarks for US, EU, and Middle East markets.',
              'Cold Chain & Warehousing: Direct logistics matching for moisture-sealed transit.',
            ],
            actionLabel: 'Setup Dried Fruit Unit',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DriedFruitUnitPage()),
            ),
          ),
          SizedBox(height: 16.h),

          // Smart Solar Dryer (live device control, Demo Mode included).
          _buildHubSection(
            context,
            icon: Icons.solar_power_rounded,
            color: Colors.deepOrange.shade800,
            title: 'Smart Solar Dryer — Live Control & Monitoring',
            subtitle: '50 kg solar dryer: connect, monitor, batch & report',
            features: const [
              'Live collector/chamber/ambient readings with stale-data flags.',
              'Demo Mode for training without hardware; Wi-Fi for ESP32.',
              'Batch history with CSV export for mandi and FSSAI records.',
            ],
            actionLabel: 'Open Smart Solar Dryer',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SmartDryerScreen()),
            ),
          ),
          SizedBox(height: 16.h),

          // Section 5.2: Vegetable Farmer Support (Dried Vegetables & Storage)
          _buildHubSection(
            context,
            icon: Icons.eco_rounded,
            color: Colors.green.shade800,
            title: '5.2 Vegetable Farmer Support — Dehydration & Storage',
            subtitle: 'Onion, tomato, garlic flakes & controlled atmosphere cold storage',
            features: [
              'Dehydration Techniques: High-nutrition retention dehydration for regional vegetables.',
              'Cold Storage Network: Connect with nearest district cold storages & warehouse receipt financing.',
              'Lab Quality Certification: Shelf-life validation and microbiological testing.',
            ],
            actionLabel: 'Connect with Storage & Labs',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StorageLabPage()),
            ),
          ),
          SizedBox(height: 16.h),

          // Section 5.3: Spice Farmer Support (Quality, Quantity & Lab Reports)
          _buildHubSection(
            context,
            icon: Icons.grain_rounded,
            color: Colors.deepOrange.shade800,
            title: '5.3 Spice Farmer Support — Quality & Spice Board Integration',
            subtitle: 'Aroma retention, pesticide residue testing & export registration',
            features: [
              'Flavour & Aroma Preservation: Post-harvest curing, solar drying, and grading.',
              'FSSAI Accredited Lab Reports: Automated upload of adulteration & chemical residue test certificates.',
              'Spice Board of India: Assisted export registration and CRES certification.',
            ],
            actionLabel: 'Upload Spice Lab Report',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpiceLabPage()),
            ),
          ),
          SizedBox(height: 16.h),

          // Section 5.4: Organic & Sustainable Agriculture Inputs
          _buildHubSection(
            context,
            icon: Icons.compost_rounded,
            color: Colors.teal.shade800,
            title: '5.4 Organic Agriculture Inputs — Plant Setup & Biocontrol',
            subtitle: 'Vermicompost, neem biopesticides, pheromone traps & Bio-fertilizers',
            features: [
              'Manufacturing Plant Blueprints: Business plans, equipment sourcing, and Central Insecticides Board compliance.',
              'EcoSusRural Marketplace Off-Take: Sell verified organic manure & biopesticides directly to registered farmers.',
              'Ayurvedic & Natural Cosmetics (B2B/B2C): Processing aloe vera, turmeric, and essential oils for premium global cosmetics brands.',
            ],
            actionLabel: 'Register Organic Input Plant',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const OrganicInputPage()),
            ),
          ),
          SizedBox(height: 16.h),

          // Section 5.5: Master Farmer Teaching & Off-Season Skilling
          _buildHubSection(
            context,
            icon: Icons.school_rounded,
            color: Colors.purple.shade800,
            title: '5.5 Master Farmer Teaching & Off-Season Skilling',
            subtitle: 'Dual income: teach your farming techniques & learn off-season trades',
            features: [
              'Teach & Earn: Publish video lectures, host paid on-farm apprenticeships, and mentor youth.',
              'Off-Season Skills (3-4 Months): Master food processing, solar pump repair, handicraft carving, and packaging.',
              'Online & Offline Modes: Downloadable courses for low-connectivity regions.',
            ],
            actionLabel: 'Join Master Farmer Faculty',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MasterFarmerPage()),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHubSection(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<String> features,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...features.map(
            (feat) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: color, size: 16.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      feat,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                padding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: TextStyle(color: color, fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

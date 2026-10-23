import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class EthicsIntegrityPledgeScreen extends ConsumerWidget {
  const EthicsIntegrityPledgeScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          ref.tr('ethicsTitle'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Banner
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4D3E), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.amber, size: 28),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'EcoSusRural Ethical Compact',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Expansion in every business of India where our core ethics, verified authenticity, and producer dignity are strictly obeyed.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13.sp, height: 1.4),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Core Ethics Pillars
          _buildPillarCard(
            context,
            icon: Icons.shield_rounded,
            color: Colors.indigo,
            title: '1. 100% Anti-Counterfeiting & Government Certification',
            description:
                'Every product claiming Geographical Indication (GI), Organic (NPOP/FSSAI), or Handicraft heritage must possess a verified government registry certificate. Lab test reports are published directly on product pages. Anonymous spot audits are conducted to prevent counterfeits.',
            badge: 'Govt Verified ✓',
          ),
          SizedBox(height: 14.h),

          _buildPillarCard(
            context,
            icon: Icons.currency_rupee_rounded,
            color: Colors.green.shade800,
            title: '2. Fair Pricing & Zero Exploitative Middlemen',
            description:
                'Producers receive direct, transparent margins. Middleman markups are eradicated. All pricing breakdowns (base cost, logistics, platform fee, GST) are transparently itemized for buyers and sellers alike.',
            badge: 'Fair Price Guarantee',
          ),
          SizedBox(height: 14.h),

          _buildPillarCard(
            context,
            icon: Icons.lock_clock_rounded,
            color: Colors.amber.shade900,
            title: '3. Escrow Buyer Protection & Penny-Drop Bank Trust',
            description:
                'Payments collected from buyers remain protected in an escrow account until the buyer receives and verifies the product. Sellers are verified via a ₹1 penny-drop mechanism linked directly to their National ID (Aadhaar/e-KYC).',
            badge: 'Escrow Protected',
          ),
          SizedBox(height: 14.h),

          _buildPillarCard(
            context,
            icon: Icons.security_rounded,
            color: Colors.red.shade800,
            title: '4. Military-Grade Security & Anti-Piracy DRM',
            description:
                'All proprietary training masterclasses, weather pattern models, and research reports are protected by OS-level screen capture blocking (FLAG_SECURE on Android, UIScreen.isCaptured on iOS) and visible/invisible user ID forensic watermarking.',
            badge: 'Military DRM Protected',
          ),
          SizedBox(height: 14.h),

          _buildPillarCard(
            context,
            icon: Icons.storage_rounded,
            color: Colors.teal.shade800,
            title: '5. India Data Residency & DPDPA 2023 Compliance',
            description:
                'In full compliance with the Digital Personal Data Protection Act 2023 and the IT Act 2000, all citizen and enterprise data is encrypted (AES-256 at rest, TLS 1.3 in transit) and strictly stored on Indian sovereign cloud servers.',
            badge: 'DPDPA 2023 Compliant',
          ),
          SizedBox(height: 24.h),

          // Pledge Verification Button
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF1B4D3E), size: 24),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'As a participant on EcoSusRural, you are protected by this legally binding integrity code.',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildPillarCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String badge,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
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
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            description,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, height: 1.4),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              badge,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

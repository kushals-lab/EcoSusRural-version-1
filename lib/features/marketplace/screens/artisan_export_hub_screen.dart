import 'dart:async' show unawaited;
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';
import 'exporter_course_page.dart';

class ArtisanExportHubScreen extends ConsumerWidget {
  const ArtisanExportHubScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          ref.tr('artisanHub'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Banner
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF1B4D3E)],
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
                    const Icon(Icons.palette_rounded, color: Colors.amber, size: 28),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Artisan Global Market & Export Hub',
                        style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Empowering India\'s master craftspeople with direct global export facilitation, fair pricing algorithms, packaging certification, and master teaching income.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.sp, height: 1.4),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Section 6.1: Global Market Access & Fair Pricing
          _buildArtisanCard(
            context,
            icon: Icons.public_rounded,
            color: Colors.indigo.shade800,
            title: '6.1 Global Market Access & Fair Price Guarantee',
            subtitle: 'IEC registration, customs clearance & fair price algorithm',
            points: [
              'Import Export Code (IEC): Assisted application with DGFT directly inside the app.',
              'Customs & Harmonized Codes: Automatic HS-Code classification for handicrafts, handlooms, and pottery.',
              'Fair Price Guarantee: Algorithmic pricing guarantees artisan cost + dignified profit margin with no middlemen markups.',
              'International Buyer Network: Curated connections with fair-trade retail chains in US, UK, EU, and Japan.',
            ],
            actionText: 'Start IEC & Export Application',
            onAction: () => _notify(context, 'Export Onboarding Toolkit'),
          ),
          SizedBox(height: 16.h),

          // Section 6.2: Logistics, Distribution & Fragile Packaging Training
          _buildArtisanCard(
            context,
            icon: Icons.local_shipping_rounded,
            color: Colors.blueGrey.shade800,
            title: '6.2 Fragile Packaging & Global Logistics Training',
            subtitle: 'Shockproof packing, transit insurance & customs tracking',
            points: [
              'Fragile Craft Packaging: Certified training on eco-friendly honeycomb paper, corrugated padding, and moisture barriers.',
              'Transit Insurance: Automated transit damage coverage through partner logistics insurers.',
              'Cross-Border Tracking: Live end-to-end milestone tracking with Shiprocket, DHL, India Post International, and FedEx.',
            ],
            actionText: 'View Packaging Certification Course',
            onAction: () => _notify(context, 'Logistics & Packaging Course'),
          ),
          SizedBox(height: 16.h),

          // Section 6.3: Master Artisan Teaching Portal
          _buildArtisanCard(
            context,
            icon: Icons.auto_stories_rounded,
            color: Colors.purple.shade800,
            title: '6.3 Master Artisan Teaching Portal & Apprenticeships',
            subtitle: 'Intergenerational knowledge transfer & dual income streams',
            points: [
              'Dual Income: Master artisans earn revenue from product sales AND from online course enrollments and live workshops.',
              'Live Demonstration Sessions: Stream high-definition craft demonstrations to international students and enthusiasts.',
              'In-Person Apprenticeships: Host youth apprentices at your village workshop bookable via EcoSusRural.',
              'Heritage Craft Preservation: Digital video archive preserving endangered Indian traditional craft techniques.',
            ],
            actionText: 'Register as Master Instructor',
            onAction: () => _notify(context, 'Master Artisan Faculty Enrollment'),
          ),
          SizedBox(height: 16.h),

          // Section 6.4: Global Exporter Certification (course + 20-Q exam)
          _buildArtisanCard(
            context,
            icon: Icons.workspace_premium_rounded,
            color: Colors.teal.shade800,
            title: '6.4 Global Exporter Certification — Course & Exam',
            subtitle: 'Application certificate + 20-question (15 MCQ + 5 written) exam',
            points: [
              'Certification Course: IEC, HS codes, incoterms, lab-report workflow and biodegradable packaging — all as video lessons.',
              '20-Question Exam: 15 MCQ auto-scored + 5 written answers on costing, storage bills and wet:dry ratios.',
              'Application Certificate: Score 11/15 with all written answers and instantly receive your Global Exporter Certificate with a verifiable Cert ID.',
            ],
            actionText: 'Start Course & Get Certificate',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ExporterCoursePage()),
            ),
          ),
          // Free course videos for buyer, seller and organisation open
          // YouTube in the browser (no plugin needed).
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openYouTube(
                  context, 'https://youtu.be/demo-exporter-cert-free'),
              icon: const Icon(Icons.youtube_searched_for, size: 16),
              label: const Text('Free course videos on YouTube'),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildArtisanCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<String> points,
    required String actionText,
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
                    Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
                    Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...points.map(
            (p) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: color, size: 16.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      p,
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
                actionText,
                style: TextStyle(color: color, fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _notify(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title launched. Preparing forms...')),
    );
  }

  static void _openYouTube(BuildContext context, String url) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video link provided for this course.')),
      );
      return;
    }
    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Open this link in your browser: $url'),
            action: SnackBarAction(
                label: 'Copy', onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard.')),
                  );
                })),
      );
      return;
    }
    try {
      if (io.Platform.isWindows) {
        unawaited(io.Process.start('cmd.exe', ['/c', 'start', url]));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening YouTube in your browser: $url')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open this link in your browser: $url')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Open this link in your browser: $url')),
      );
    }
  }
}

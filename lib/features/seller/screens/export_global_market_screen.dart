import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExportGlobalMarketScreen extends ConsumerWidget {
  const ExportGlobalMarketScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Export / Global Market',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B4D3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.public, color: Colors.white, size: 28),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Global export readiness',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Low-cost premium export training, certification support, and international buyer matching for rural brands.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 12.sp, height: 1.5),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _sectionTitle('Export packages'),
          _courseTile('Premium Market Entry Program', '₹4,999 / course', 'Export strategy, compliance, packaging, and buyer discovery.'),
          _courseTile('Global Standards Certification', '₹7,499 / course', 'International compliance walkthrough for food, handicraft, and textile exporters.'),
          _courseTile('Buyer Connect & Promotion', '₹9,999 / package', 'Marketplace ranking and onboarding support for global sales channels.'),
          SizedBox(height: 16.h),
          _sectionTitle('Document upload'),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _uploadRow(context, 'Business registration', Icons.upload_file_outlined),
                _uploadRow(context, 'Export license / certificate', Icons.upload_file_outlined),
                _uploadRow(context, 'Product photos & HS code docs', Icons.upload_file_outlined),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _sectionTitle('Service fee'),
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
                Text('Nominal platform fee', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 8.h),
                Text('₹1,499 one-time onboarding fee for compliance review and buyer assistance.', style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                SizedBox(height: 12.h),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export onboarding fee payment initiated.')),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
      ),
    );
  }

  Widget _courseTile(String title, String price, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.auto_awesome, color: _primaryGreen, size: 26),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 2.h),
                Text(price, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _primaryGreen)),
                SizedBox(height: 4.h),
                Text(description, style: TextStyle(fontSize: 11.sp, color: Colors.grey[700], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadRow(BuildContext context, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(icon, color: _primaryGreen, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload dialog for $label opened.')),
              );
            },
            icon: const Icon(Icons.cloud_upload_outlined, color: _primaryGreen),
          ),
        ],
      ),
    );
  }
}

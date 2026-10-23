import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../expert_advice/screens/expert_advice_screen.dart';
import '../../seller/screens/seller_dashboard_screen.dart';

/// Checkout context passed from a subscription flow so that EcoBharatPay
/// can route a verified payment to this operational dashboard.
class PaymentSuccessContext {
  final String title;
  final String subtitle;
  final List<SubscriptionQuotaSummary> quotas;

  const PaymentSuccessContext({
    required this.title,
    required this.subtitle,
    required this.quotas,
  });
}

/// Summary of the active plan quotas shown on the success dashboard.
class SubscriptionQuotaSummary {
  final String label;
  final String value;
  final double fraction; // 0..1 gauge fill
  final IconData icon;

  const SubscriptionQuotaSummary({
    required this.label,
    required this.value,
    required this.fraction,
    required this.icon,
  });
}

/// Active Subscription & Operational Dashboard - the page EcoBharatPay
/// opens after a verified payment (Blueprint 7.2, State 4).
///
/// Shows the order confirmation with a GST invoice download, visual gauges
/// for active quotas and quick-launch tiles.
class PaymentSuccessScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String txnId;
  final List<SubscriptionQuotaSummary> quotas;

  const PaymentSuccessScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.txnId,
    required this.quotas,
  });

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Active Subscription',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), _primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 48),
                ),
                SizedBox(height: 12.h),
                Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 6.h),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                SizedBox(height: 10.h),
                Text('Txn ID: $txnId', style: TextStyle(color: Colors.white60, fontSize: 10.sp)),
              ]),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryGreen),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('GST invoice PDF prepared and saved to your device (demo).')));
                },
                icon: const Icon(Icons.download_outlined, color: _primaryGreen),
                label: const Text('Download GST Invoice PDF',
                    style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20.h),
            Text('Active Quotas',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 10.h),
            ...quotas.map((q) => Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(q.icon, color: _primaryGreen, size: 18),
                      SizedBox(width: 8.w),
                      Expanded(child: Text(q.label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]))),
                      Text(q.value,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                    ]),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: LinearProgressIndicator(
                        value: q.fraction.clamp(0.0, 1.0),
                        minHeight: 8.h,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
                      ),
                    ),
                  ]),
                )),
            SizedBox(height: 8.h),
            Text('Quick Launch',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 10.h),
            Row(children: [
              _quickTile(context, Icons.post_add, 'Post First Product Listing', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerDashboardScreen()));
              }),
              SizedBox(width: 10.w),
              _quickTile(context, Icons.smart_toy, 'Launch EcoSusRural AI', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
              }),
              SizedBox(width: 10.w),
              _quickTile(context, Icons.support_agent, 'Book Expert Advice', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpertAdviceScreen()));
              }),
            ]),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen, padding: EdgeInsets.symmetric(vertical: 12.h)),
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Go to Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _quickTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(children: [
            Icon(icon, color: _primaryGreen),
            SizedBox(height: 6.h),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[800])),
          ]),
        ),
      ),
    );
  }
}

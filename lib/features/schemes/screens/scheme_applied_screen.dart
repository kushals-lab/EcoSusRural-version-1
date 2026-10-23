import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../../payments/screens/eco_bharat_pay_screen.dart';
import '../models/scheme_application_model.dart';
import 'my_applications_screen.dart';

/// Shown right after the captcha + email OTP verification succeed: confirms
/// that the application was applied successfully and hands the user over to
/// the EcoBharatPay section to pay the small application service fee.
class SchemeAppliedScreen extends ConsumerWidget {
  const SchemeAppliedScreen({super.key, required this.applicationId});

  final String applicationId;

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.tr;
    final application = ref
        .watch(schemeApplicationsProvider)
        .where((a) => a.id == applicationId)
        .firstOrNull;

    if (application == null) {
      // Should never happen, but never crash the flow.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          application.schemeName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _primaryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            Center(
              child: Container(
                width: 110.r,
                height: 110.r,
                decoration: BoxDecoration(
                  color: _primaryGreen.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryGreen, width: 2),
                ),
                child: Icon(Icons.task_alt, size: 54.r, color: _primaryGreen),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade600, size: 22.r),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    t('appliedSuccessfully'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'Application ID ${application.id} • ${application.schemeName}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 22.h),
            _AppliedSummaryCard(application: application),
            SizedBox(height: 20.h),
            _PayFeeButton(application: application),
            SizedBox(height: 10.h),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyApplicationsScreen()),
                ),
                child: Text(
                  t('myApplications'),
                  style: TextStyle(fontSize: 13.sp, color: _primaryGreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppliedSummaryCard extends StatelessWidget {
  final SchemeApplication application;

  const _AppliedSummaryCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Department', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              Text(application.department, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Platform Fee', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              Text('₹${application.feeInr.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayFeeButton extends StatelessWidget {
  final SchemeApplication application;

  const _PayFeeButton({required this.application});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1B4D3E),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      onPressed: () async {
        final success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EcoBharatPayScreen(
              amount: application.feeInr,
              purpose: 'Platform fee for ${application.schemeName}',
              referenceId: application.id,
            ),
          ),
        );
        if (!context.mounted) return;
        if (success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Successful!')),
          );
        }
      },
      icon: const Icon(Icons.payment, color: Colors.white),
      label: Text(
        'Pay Platform Fee',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../../payments/screens/eco_bharat_pay_screen.dart';
import '../models/scheme_application_model.dart';
import '../models/scheme_model.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.tr;
    final applications = ref.watch(schemeApplicationsProvider);
    final resolved = applications
        .map((a) => SchemeApplicationsNotifier.resolveReview(a, kSchemes.firstWhere((s) => s.id == a.schemeId)))
        .toList();
    if (resolved.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F6),
        appBar: AppBar(backgroundColor: Colors.white, elevation: 1, title: Text(t('myApplications'), style: const TextStyle(fontWeight: FontWeight.bold))),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(t('myApplications'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            SizedBox(height: 8.h),
            Text('No applications yet. Browse schemes to apply.', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(t('backToDetails')),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 48.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
            ),
          ]),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 1, title: Text(t('myApplications'), style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          // Platform fee / assistance banner
          Container(
            padding: EdgeInsets.all(12.r),
            color: _primaryGreen.withValues(alpha: 0.08),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.volunteer_activism, size: 20.sp, color: _primaryGreen),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'EcoSusRural provides end-to-end application assistance. A nominal platform fee of ₹50 applies for document verification and processing.',
                    style: TextStyle(fontSize: 11.sp, color: Colors.black87, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: resolved.length,
                itemBuilder: (context, index) => _ApplicationCard(application: resolved[index], t: t),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final SchemeApplication application;
  final String Function(String key) t;

  const _ApplicationCard({required this.application, required this.t});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    final statusText = switch (application.status) {
      ApplicationStatus.submitted => t('statusSubmitted'),
      ApplicationStatus.underReview => t('statusUnderReview'),
      ApplicationStatus.approved => t('statusApproved'),
      ApplicationStatus.rejected => t('statusRejected'),
      ApplicationStatus.actionRequired => t('statusActionRequired'),
    };

    return Card(
      margin: EdgeInsets.only(bottom: 14.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: _primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(application.schemeIcon, style: TextStyle(fontSize: 22.sp)),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.schemeName,
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 2.h),
                      Text('${t('kindSchemes') == 'Schemes' ? application.kind : application.kind} \u2022 ${application.type}',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _statusColor(application.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(statusText,
                      style: TextStyle(fontSize: 10.sp, color: _statusColor(application.status), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _InfoRow(icon: Icons.folder_outlined, label: t('department'), value: application.department),
            SizedBox(height: 6.h),
            _InfoRow(icon: Icons.public, label: t('fileCurrentlyAt'), value: application.currentDepartment),
            SizedBox(height: 6.h),
            _InfoRow(
              icon: Icons.schedule,
              label: t('expectedResult'),
              value: '${application.expectedResultAt.toLocal().toIso8601String().split('T')[0]} (${application.processingDays} ${t('approxWorkingDays')})',
            ),
            ...application.documentValues.entries.take(3).map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text('${e.key}: ${e.value}',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                      ),
                    ],
                  ),
                )),
            
            SizedBox(height: 16.h),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: 12.h),
            
            // Document Upload & Payment Section
            Text(
              'Required Actions',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryGreen,
                      side: BorderSide(color: _primaryGreen.withValues(alpha: 0.5)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Document picker opened.')),
                      );
                    },
                    icon: Icon(Icons.upload_file, size: 16.sp),
                    label: Text(
                      'Upload Docs',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () async {
                      final success = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EcoBharatPayScreen(
                            amount: 50.00,
                            purpose: 'Platform fee for ${application.schemeName}',
                            referenceId: 'APP${application.id.toUpperCase()}',
                          ),
                        ),
                      );
                      if (!context.mounted) return;
                      
                      if (success == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment processed successfully. Processing started.')),
                        );
                      }
                    },
                    icon: Icon(Icons.payment, size: 16.sp, color: Colors.white),
                    label: Text(
                      'Pay ₹50 Fee',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _statusColor(ApplicationStatus status) {
    return switch (status) {
      ApplicationStatus.submitted => Colors.blue.shade600,
      ApplicationStatus.underReview => Colors.orange.shade600,
      ApplicationStatus.approved => Colors.green.shade600,
      ApplicationStatus.rejected => Colors.red.shade600,
      ApplicationStatus.actionRequired => Colors.deepOrange.shade600,
    };
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade600),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        ),
        Text(value, style: TextStyle(fontSize: 12.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

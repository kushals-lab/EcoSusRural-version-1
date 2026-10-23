import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../models/scheme_model.dart';

/// Detail page for one scheme / insurance / scholarship.
/// All prose is rendered in the user's current locale (no hard-coded bilingual
/// strings like "Apply for X / आवेदन करें" any more).
class SchemeDetailScreen extends ConsumerStatefulWidget {
  const SchemeDetailScreen({super.key, required this.scheme});
  final SchemeModel scheme;

  @override
  ConsumerState<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends ConsumerState<SchemeDetailScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    final t = ref.tr;
    final scheme = widget.scheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          scheme.name,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B4D3E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(child: Text(scheme.icon, style: TextStyle(fontSize: 28.sp))),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme.name,
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${t('kindSchemes') == 'Schemes' ? scheme.category : scheme.category} ${t(scheme.kind.toLowerCase())} • ${scheme.status}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Description
            Text(t('aboutScheme'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 8.h),
            Text(scheme.description, style: TextStyle(fontSize: 14.sp, color: Colors.grey[800], height: 1.6)),

            SizedBox(height: 20.h),

            // Eligibility
            _sectionCard(
              icon: Icons.verified_user,
              title: t('eligibilityCriteria'),
              children: [
                Text(scheme.eligibility, style: TextStyle(fontSize: 13.sp, color: Colors.grey[800])),
              ],
            ),

            SizedBox(height: 16.h),

            // Documents Required
            _sectionCard(
              icon: Icons.description,
              title: 'Documents Required',
              children: [
                ...scheme.documents.map((doc) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: _primaryGreen, size: 16),
                          SizedBox(width: 8.w),
                          Text(doc, style: TextStyle(fontSize: 13.sp, color: Colors.grey[800])),
                        ],
                      ),
                    )),
              ],
            ),

            SizedBox(height: 16.h),

            // Application Steps — all labels in the user's language
            _sectionCard(
              icon: Icons.rocket_launch,
              title: t('applicationProcess'),
              children: [
                Text('1. ${t('profileAutoFill')}', style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
                SizedBox(height: 4.h),
                Text('2. ${t('uploadDocuments')}', style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
                SizedBox(height: 4.h),
                Text('3. ${t('submitFeeDisclosed')}', style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
                SizedBox(height: 4.h),
                Text('4. ${t('trackInMyApplications')}', style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
              ],
            ),

            SizedBox(height: 28.h),

            // Apply Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                minimumSize: Size(double.infinity, 54.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: _isApplying ? null : () => _apply(context),
              child: _isApplying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('${t('applyFor')} ${scheme.name}',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryGreen, size: 20),
              SizedBox(width: 8.w),
              Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }

  void _apply(BuildContext context) {
    final t = ref.tr;
    setState(() => _isApplying = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || !context.mounted) return;
      setState(() => _isApplying = false);
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('applicationSubmitted'),
            ],
          ),
          content: Text(
            '${t('applicationSubmittedMsg')} ${widget.scheme.name}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t('ok')),
            ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../../auth/screens/phone_login_screen.dart';
import '../providers/legal_provider.dart';

class LegalAgreementScreen extends ConsumerStatefulWidget {
  final bool isReadOnly;
  const LegalAgreementScreen({super.key, this.isReadOnly = false});

  @override
  ConsumerState<LegalAgreementScreen> createState() =>
      _LegalAgreementScreenState();
}

class _LegalAgreementScreenState extends ConsumerState<LegalAgreementScreen> {
  @override
  Widget build(BuildContext context) {
    final legalState = ref.watch(legalProvider);
    final legalNotifier = ref.read(legalProvider.notifier);
    const primaryGreen = Color(0xFF1B4D3E);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: Text(
          ref.tr('legalAgreementTitle'),
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: primaryGreen),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        // Re-read mode (opened from Settings): show a back button so the user
        // returns to exactly where they left off instead of being forced
        // forward into login/registration.
        automaticallyImplyLeading: widget.isReadOnly,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: primaryGreen),
            tooltip: ref.tr('legalAgreementListen'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ref.tr('legalAgreementAudioNarration'))),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        // Single scroll context: the document and the consent checkboxes scroll
        // together. (The previous nested SingleChildScrollView for the document
        // shrink-wrapped to full height, so it consumed every drag gesture while
        // being unable to scroll — freezing the whole page.)
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              // Legal document card.
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  ref.tr('legalAgreementDocument'),
                  style: TextStyle(
                      fontSize: 13.sp, color: Colors.grey[800], height: 1.5),
                ),
              ),
              SizedBox(height: 12.h),

              // Consent checkboxes (hidden in read-only re-read mode).
              if (!widget.isReadOnly) ...[
                checkerTile(
                  title: ref.tr('legalAgreementTerms'),
                  value: legalState.acceptedTerms,
                  onChanged: (val) => legalNotifier.toggleTerms(val ?? false),
                ),
                checkerTile(
                  title: ref.tr('legalAgreementPrivacy'),
                  value: legalState.acceptedPrivacy,
                  onChanged: (val) => legalNotifier.togglePrivacy(val ?? false),
                ),
                checkerTile(
                  title: ref.tr('legalAgreementIntegrity'),
                  value: legalState.acceptedIntegrity,
                  onChanged: (val) =>
                      legalNotifier.toggleIntegrity(val ?? false),
                  isHighlight: true,
                ),
              ],
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),

      // Pinned action bar — "Accept & Continue" is always visible and tappable
      // once all three consents are given.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: (widget.isReadOnly || legalState.canProceed)
                  ? primaryGreen
                  : Colors.grey.shade400,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: widget.isReadOnly
                // Re-read mode: simply go back to where the user left off.
                ? () => Navigator.of(context).pop()
                : (legalState.canProceed
                    ? () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const PhoneLoginScreen(),
                          ),
                        );
                      }
                    : null),
            child: Text(
              widget.isReadOnly ? ref.tr('back') : ref.tr('acceptContinue'),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget checkerTile({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1B4D3E),
              checkColor: Colors.white,
              side: const BorderSide(color: Colors.black87),
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              softWrap: true,
              style: TextStyle(
                fontSize: 12.sp,
                color: isHighlight ? Colors.red.shade700 : Colors.black87,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

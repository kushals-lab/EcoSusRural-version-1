import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/language_provider.dart';
import '../../../core/security/captcha.dart';
import '../models/scheme_application_model.dart';
import '../models/scheme_model.dart';
import 'scheme_applied_screen.dart';

/// In-app application flow for a scheme / insurance / scholarship entry.
///
/// Step 1: applicant details plus every document the scheme demands (all
/// mandatory unless marked optional), protected by a captcha on this page.
/// Step 2: email OTP verification with its own captcha on the same page.
/// Submitting lands on the "Applied successfully" screen, which forwards to the
/// EcoBharatPay service-fee payment.
class SchemeApplicationScreen extends ConsumerStatefulWidget {
  const SchemeApplicationScreen({
    super.key,
    required this.scheme,
    this.prefillDocumentValues = const {},
    this.prefillName = '',
    this.prefillEmail = '',
  });

  final SchemeModel scheme;

  /// Previously entered values, used by "Reapply" in My Applications.
  final Map<String, String> prefillDocumentValues;
  final String prefillName;
  final String prefillEmail;

  @override
  ConsumerState<SchemeApplicationScreen> createState() =>
      _SchemeApplicationScreenState();
}

class _SchemeApplicationScreenState
    extends ConsumerState<SchemeApplicationScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  int _step = 0;
  bool _submitting = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final GlobalKey<CaptchaFieldState> _captchaKey = GlobalKey();
  final GlobalKey<CaptchaFieldState> _emailCaptchaKey = GlobalKey();

  late final Map<String, TextEditingController> _documentControllers;
  final Set<String> _attachedDocuments = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefillName);
    _emailController = TextEditingController(text: widget.prefillEmail);
    _documentControllers = {
      for (final field in widget.scheme.documentFields)
        field.label: TextEditingController(
          text: widget.prefillDocumentValues[field.label] ?? '',
        ),
    };
    for (final entry in widget.prefillDocumentValues.entries) {
      final matches = widget.scheme.documentFields
          .where((f) => f.label == entry.key)
          .toList();
      if (matches.isNotEmpty &&
          matches.first.kind == 'upload' &&
          entry.value.isNotEmpty) {
        _attachedDocuments.add(entry.key);
      }
    }
    _loadSavedApplicant();
  }

  Future<void> _loadSavedApplicant() async {
    if (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        if (_nameController.text.isEmpty) {
          _nameController.text = prefs.getString('ecosus.applicant.name') ?? '';
        }
        if (_emailController.text.isEmpty) {
          _emailController.text =
              prefs.getString('ecosus.applicant.email') ?? '';
        }
      });
    } catch (_) {
      // Prefill is best-effort.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _captchaController.dispose();
    for (final controller in _documentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Validates every mandatory document field of this scheme.
  bool _documentsComplete() {
    for (final field in widget.scheme.documentFields) {
      if (field.optional) continue;
      if (field.kind == 'upload') {
        if (!_attachedDocuments.contains(field.label)) {
          _snack('Please attach "${field.label}" to continue.');
          return false;
        }
      } else if (_documentControllers[field.label]!.text.trim().isEmpty) {
        _snack('Please enter "${field.label}" to continue.');
        return false;
      }
    }
    return true;
  }

  Map<String, String> get _documentValues => {
        for (final field in widget.scheme.documentFields)
          field.label: field.kind == 'upload'
              ? (_attachedDocuments.contains(field.label)
                  ? '${field.label}.pdf'
                  : '')
              : _documentControllers[field.label]!.text.trim(),
      };

  void _continueFromDetails() {
    if (_nameController.text.trim().isEmpty) {
      _snack('Please enter the applicant name.');
      return;
    }
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      _snack('Please enter a valid email address.');
      return;
    }
    if (!_documentsComplete()) return;
    // The captcha on this page must be solved before the next page opens.
    if (!(_captchaKey.currentState?.validate() ?? false)) {
      _snack(ref.tr('wrongCaptcha'));
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _verifyAndSubmit() async {
    if (_otpController.text.trim().length != 6) {
      _snack('Enter the 6-digit OTP sent to your email.');
      return;
    }
    if (!(_emailCaptchaKey.currentState?.validate() ?? false)) {
      _snack(ref.tr('wrongCaptcha'));
      return;
    }

    setState(() => _submitting = true);
    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final application = ref.read(schemeApplicationsProvider.notifier).add(
            scheme: widget.scheme,
            applicantName: name,
            applicantEmail: email,
            documentValues: _documentValues,
          );
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ecosus.applicant.name', name);
        await prefs.setString('ecosus.applicant.email', email);
      } catch (_) {
        // Persisting the applicant profile is best-effort.
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SchemeAppliedScreen(applicationId: application.id),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.tr;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          '${t('applyFor')} ${widget.scheme.name}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _primaryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: _step == 0 ? _buildDetailsStep(t) : _buildEmailStep(t),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: _primaryGreen),
      ),
    );
  }

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: _primaryGreen,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _uploadRow(SchemeDocumentField field) {
    final attached = _attachedDocuments.contains(field.label);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.optional ? '${field.label} (optional)' : field.label,
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              ),
              if (field.hint.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  field.hint,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: attached ? Colors.green.shade700 : _primaryGreen,
            side: BorderSide(
              color: attached ? Colors.green.shade600 : _primaryGreen,
            ),
          ),
          onPressed: () => setState(() => _attachedDocuments.add(field.label)),
          icon: Icon(
            attached ? Icons.check_circle : Icons.upload_file,
            size: 16,
          ),
          label: Text(
            attached ? ref.tr('documentAttached') : ref.tr('attachDocument'),
            style: TextStyle(fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(String Function(String key) t) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            '${t('applyFor')} ${widget.scheme.name}',
            '${widget.scheme.type} • ${widget.scheme.kind} • ${widget.scheme.category}',
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _nameController,
            decoration: _fieldDecoration('Applicant name', Icons.person),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _fieldDecoration('Email address', Icons.alternate_email),
          ),
          SizedBox(height: 20.h),

          // Per-scheme documents (e.g. MSME: loan sanction letter, MSME
          // registration number, GSTIN). Mandatory ones cannot be skipped.
          _card(
            icon: Icons.folder_shared,
            title: t('documentsRequired'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final field in widget.scheme.documentFields) ...[
                  if (field.kind == 'upload')
                    _uploadRow(field)
                  else
                    TextField(
                      controller: _documentControllers[field.label],
                      decoration: _fieldDecoration(
                        field.optional ? '${field.label} (optional)' : field.label,
                        Icons.badge,
                      ).copyWith(
                        helperText: field.hint.isEmpty ? null : field.hint,
                      ),
                    ),
                  SizedBox(height: 12.h),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Nominal service fee, disclosed before the EcoBharatPay payment.
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 16.r, color: Colors.amber.shade900),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${t('applicationFee')}: ₹${widget.scheme.applicationFeeInr.toStringAsFixed(0)} '
                    '(paid via EcoBharatPay after verification).',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.amber.shade900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Captcha on this page — the flow cannot move on without it.
          _card(
            icon: Icons.security,
            title: t('captchaTitle'),
            child: CaptchaField(
              key: _captchaKey,
              controller: _captchaController,
              label: t('captchaTitle'),
              hint: ref.tr('enterCaptcha'),
              wrongMessage: ref.tr('wrongCaptcha'),
              note: 'Required on every page of the application flow.',
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              minimumSize: Size(double.infinity, 54.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: _continueFromDetails,
            child: Text(
              'Continue to ${t('emailOtpStep')}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep(String Function(String key) t) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
            t('emailOtpStep'),
            'A 6-digit OTP has been sent to ${_emailController.text.trim()}.',
          ),
          SizedBox(height: 16.h),
          _card(
            icon: Icons.mark_email_read,
            title: t('emailOtpStep'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: _fieldDecoration('Enter OTP', Icons.password)
                      .copyWith(counterText: ''),
                ),
                SizedBox(height: 16.h),
                // Captcha on the same page as the OTP.
                CaptchaField(
                  key: _emailCaptchaKey,
                  controller: _captchaController,
                  label: t('captchaTitle'),
                  hint: ref.tr('enterCaptcha'),
                  wrongMessage: ref.tr('wrongCaptcha'),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              minimumSize: Size(double.infinity, 54.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: _submitting ? null : _verifyAndSubmit,
            child: _submitting
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    '${t('applyFor')} & Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _step = 0),
              child: const Text('Back to details'),
            ),
          ),
        ],
      ),
    );
  }
}

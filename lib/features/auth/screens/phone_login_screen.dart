import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'otp_verification_screen.dart';
import 'registration_screen.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/language_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.sendOtp(_phoneController.text);

    // Navigate to the OTP verification screen after a brief moment so the
    // "sending" state is visible.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OtpVerificationScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.read(languageProvider.notifier).translate;
    final lang = ref.watch(languageProvider.select((s) => s.code));
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: Text(
          t('phoneLogin', lang),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Icon(Icons.verified_user_outlined, color: _primaryGreen, size: 56.r),
                SizedBox(height: 16.h),
                Text(
                  ref.tr('welcomeBack'),
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
                ),
                SizedBox(height: 8.h),
                Text(
                  ref.tr('loginSubtitle'),
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700], height: 1.5),
                ),
                SizedBox(height: 40.h),

                // Phone Number Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: ref.tr('mobileNumber'),
                    counterText: '',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12.w, top: 12.h),
                      child: Text('+91  ', style: TextStyle(fontSize: 18.sp, color: _primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 60.w, minHeight: 48.h),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: _primaryGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ref.tr('mobileRequired');
                    }
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                      return ref.tr('mobileInvalid');
                    }
                    return null;
                  },
                ),

                if (authState.errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Text(authState.errorMessage!, style: const TextStyle(color: Colors.red)),
                ],

                SizedBox(height: 40.h),

                // Send OTP Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    minimumSize: Size(double.infinity, 54.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: authState.isLoading ? null : _sendOtp,
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          ref.tr('sendOtp'),
                          style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),

                SizedBox(height: 16.h),

                // Create Account Link
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_add, color: _primaryGreen),
                    label: Text(
                      ref.tr('createAccountLink'),
                      style: const TextStyle(color: _primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Language change link
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      final notifier = ref.read(languageProvider.notifier);
                      notifier.changeLanguage(lang == 'en' ? 'hi' : 'en');
                    },
                    icon: const Icon(Icons.language, color: _primaryGreen),
                    label: Text(
                      t('changeLanguage', lang),
                      style: const TextStyle(color: _primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

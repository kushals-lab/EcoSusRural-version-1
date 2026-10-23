import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/screens/farmer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../dashboard/screens/main_dashboard_screen.dart';
import '../providers/auth_provider.dart';
// Note: You may need to add 'pin_code_fields' to pubspec.yaml for a fancy OTP UI later,
// but we will use a standard TextField for now to keep dependencies light.

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    const primaryGreen = Color(0xFF1B4D3E);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryGreen),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            authNotifier.reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter OTP',
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
              SizedBox(height: 8.h),
              Text(
                'We have sent a 6-digit code to ${authState.phoneNumber}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
              SizedBox(height: 40.h),
              
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.sp, letterSpacing: 8),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "------",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              ),

              if (authState.errorMessage != null) ...[
                SizedBox(height: 8.h),
                Center(child: Text(authState.errorMessage!, style: const TextStyle(color: Colors.red))),
              ],

              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  minimumSize: Size(double.infinity, 54.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: authState.isLoading
    ? null
    : () async {
        if (_otpController.text.length == 6) {
          bool success = await authNotifier.verifyOtp(_otpController.text);
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successful!')),
            );

            // Farm profile is for FARMERS ONLY. Users who registered with a
            // different role (sarpanch, artisan, MSME, NGO head, …) go
            // straight to the dashboard.
            final prefs = await SharedPreferences.getInstance();
            final userRole = prefs.getString('ecosus.user.role') ?? '';
            final isFarmer = userRole.isEmpty || userRole == 'Farmer' || userRole == 'किसान';
            if (!mounted || !context.mounted) return;
            if (isFarmer) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FarmerProfileScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
              );
            }
          }
        }
      },
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Verify & Continue',
                        style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
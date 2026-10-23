// Temporary bisect test: pumps screens in isolation to find layout crashes.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eco_sus_rural/features/legal/screens/legal_agreement_screen.dart';
import 'package:eco_sus_rural/features/auth/screens/phone_login_screen.dart';
import 'package:eco_sus_rural/features/auth/screens/otp_verification_screen.dart';
import 'package:eco_sus_rural/features/profile/screens/farmer_profile_screen.dart';
import 'package:eco_sus_rural/features/dashboard/screens/main_dashboard_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget _wrap(Widget home) => ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (_, __) => MaterialApp(home: home),
      ),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('legal alone', (tester) async {
    await tester.pumpWidget(_wrap(const LegalAgreementScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('phone login alone', (tester) async {
    await tester.pumpWidget(_wrap(const PhoneLoginScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('otp alone', (tester) async {
    await tester.pumpWidget(_wrap(const OtpVerificationScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('farmer profile alone', (tester) async {
    await tester.pumpWidget(_wrap(const FarmerProfileScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('dashboard alone', (tester) async {
    await tester.pumpWidget(_wrap(const MainDashboardScreen()));
    await tester.pumpAndSettle();
  });
}

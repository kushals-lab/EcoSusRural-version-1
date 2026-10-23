import 'package:eco_sus_rural/features/auth/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpRegistration(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const ProviderScope(
        child: ScreenUtilInit(
          designSize: Size(390, 844),
          minTextAdapt: true,
          child: MaterialApp(home: RegistrationScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseTypeAndContinue(
    WidgetTester tester,
    String accountType,
  ) async {
    await tester.tap(find.text(accountType));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }

  testWidgets('Buyer selection advances from account type to details', (
    tester,
  ) async {
    await pumpRegistration(tester);
    expect(find.text('Choose your account type'), findsOneWidget);
    await chooseTypeAndContinue(tester, 'Buyer');
    expect(find.text('Step 1: Personal Details'), findsOneWidget);
  });

  testWidgets('Seller selection advances from account type to details', (
    tester,
  ) async {
    await pumpRegistration(tester);
    await chooseTypeAndContinue(tester, 'Seller');
    expect(find.text('Step 1: Personal Details'), findsOneWidget);
  });

  testWidgets('Organisation selection advances from account type to details', (
    tester,
  ) async {
    await pumpRegistration(tester);
    await chooseTypeAndContinue(tester, 'Organisation');
    expect(find.text('Step 1: Personal Details'), findsOneWidget);
  });

  testWidgets('seller flow offers role chips on the documents step', (
    tester,
  ) async {
    await pumpRegistration(tester);
    await chooseTypeAndContinue(tester, 'Seller');

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test Seller');
    await tester.enterText(fields.at(1), '9876543210');
    await tester.enterText(fields.at(2), 'seller@example.com');
    await tester.enterText(fields.at(3), 'Village Road, District');
    await tester.enterText(fields.at(4), '411001');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Select your role'), findsOneWidget);

    await tester.tap(find.text('Farmer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Artisan'));
    await tester.pumpAndSettle();

    final farmerChip =
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Farmer'));
    final artisanChip =
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Artisan'));
    expect(farmerChip.selected, isTrue);
    expect(artisanChip.selected, isTrue);
  });

  testWidgets('organisation flow offers NGO, SHG, Panchayat and FPO choices', (
    tester,
  ) async {
    await pumpRegistration(tester);
    await chooseTypeAndContinue(tester, 'Organisation');

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Green Valley NGO');
    await tester.enterText(fields.at(1), 'Test Head');
    await tester.enterText(fields.at(2), 'Test Member');
    await tester.enterText(fields.at(3), '9876543210');
    await tester.enterText(fields.at(4), 'head@example.com');
    await tester.enterText(fields.at(5), 'Village Road, District');
    await tester.enterText(fields.at(6), '411001');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Organisation type'), findsOneWidget);
    for (final orgType in ['NGO', 'SHG', 'Gram Panchayat', 'FPO']) {
      expect(find.text(orgType), findsOneWidget);
    }
  });
}

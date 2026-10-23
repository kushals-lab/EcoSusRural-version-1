// End-to-end smoke test: drives the real onboarding flow headlessly.
//
//   Language gateway -> legal agreement -> phone login -> OTP -> farm
//   profile -> main dashboard.
//
// It uses the real app widget (EcoSusRuralApp), the real providers, and the
// local OTP flow (dev code 123456), so any runtime error in the core journey
// surfaces here without needing a device or the backend.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eco_sus_rural/main.dart';

Future<void> _pumpFrames(WidgetTester tester,
    {Duration duration = const Duration(milliseconds: 100)}) async {
  await tester.pump(duration);
  await tester.pump(duration);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

Future<void> _acceptLegalAgreement(WidgetTester tester) async {
  final accept = find.widgetWithText(ElevatedButton, 'Accept & Continue');
  expect(tester.widget<ElevatedButton>(accept).onPressed, isNull);
  expect(find.byType(Checkbox), findsNWidgets(3));
  for (var i = 0; i < 3; i++) {
    final checkbox = find.byType(Checkbox).at(i);
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
  }
  expect(tester.widget<ElevatedButton>(accept).onPressed, isNotNull);
  await tester.tap(accept);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'full onboarding: language -> legal -> phone login -> OTP -> profile -> dashboard',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: EcoSusRuralApp()));
      await _pumpFrames(tester);

      // 1. Language gateway is shown.
      expect(find.text('Select Language'), findsOneWidget);

      // Narrow the list down so the English tile is on screen.
      await tester.enterText(find.byType(TextField).first, 'english');
      await _pumpFrames(tester);

      // Tap the English tile -> confirmation bottom sheet.
      await tester.tap(find.text('English').first);
      await tester.pumpAndSettle();
      expect(find.text('Confirm & Continue'), findsOneWidget);

      // Confirm -> legal agreement screen.
      await tester.tap(find.text('Confirm & Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Accept & Continue'), findsOneWidget);

      // Scroll to and accept all three required consents.
      await _acceptLegalAgreement(tester);

      // 2. Phone login screen.
      expect(find.text('Login with Mobile'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, '9876543210');
      await _pumpFrames(tester);

      await _tapVisible(tester, find.text('Send OTP'));
      // 300ms navigation delay + 600ms simulated OTP latency.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // 3. OTP verification screen.
      expect(find.text('Enter OTP'), findsOneWidget);
      expect(find.textContaining('9876543210'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '123456');
      await _pumpFrames(tester);

      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();

      // 4. Farm profile screen.
      expect(find.text('Setup Farm Profile'), findsOneWidget);

      // The save button must be disabled while name/land are empty.
      final completeFinder = find.text('Complete Setup / पूरा करें');
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                  of: completeFinder, matching: find.byType(ElevatedButton)),
            )
            .onPressed,
        isNull,
      );

      await tester.enterText(find.byType(TextField).at(0), 'Test Farmer');
      await tester.enterText(find.byType(TextField).at(1), '2.5');
      await _pumpFrames(tester);

      // Now it must be enabled.
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                  of: completeFinder, matching: find.byType(ElevatedButton)),
            )
            .onPressed,
        isNotNull,
      );

      await _tapVisible(tester, completeFinder);
      await tester.pumpAndSettle();

      // 5. Main dashboard.
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
    },
  );

  testWidgets(
    'wrong OTP is rejected with an error and no navigation',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: EcoSusRuralApp()));
      await _pumpFrames(tester);

      await tester.enterText(find.byType(TextField).first, 'english');
      await _pumpFrames(tester);
      await tester.tap(find.text('English').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm & Continue'));
      await tester.pumpAndSettle();

      await _acceptLegalAgreement(tester);

      await tester.enterText(find.byType(TextFormField).first, '9876543210');
      await _pumpFrames(tester);
      await _tapVisible(tester, find.text('Send OTP'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '000000');
      await _pumpFrames(tester);
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();

      // Error message shown, still on the OTP screen.
      expect(find.text('Invalid OTP Code'), findsOneWidget);
      expect(find.text('Enter OTP'), findsOneWidget);
      expect(find.text('Setup Farm Profile'), findsNothing);
    },
  );
}

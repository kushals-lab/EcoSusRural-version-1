import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_sus_rural/features/smart_dryer/screens/dryer_suite_screen.dart';
import 'package:eco_sus_rural/features/smart_dryer/screens/smart_dryer_screen.dart';
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  testWidgets('legacy dryer screen renders monitor tabs offline',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (_, __) =>
            const MaterialApp(home: SmartDryerScreen()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Smart Solar Dryer'), findsOneWidget);
    expect(find.text('Monitor'), findsOneWidget);
    expect(find.text('Control'), findsOneWidget);
    expect(find.text('Batch'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('suite exposes spec pages A-F via drawer and navigates',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (_, __) =>
            const MaterialApp(home: DryerSuiteScreen()),
      ),
    ));
    await tester.pumpAndSettle();
    // Home page (A) renders its quick actions.
    expect(find.text('Select crop'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);

    // IndexedStack keeps every page in the tree, so scope drawer lookups
    // to the Drawer to avoid label collisions with page titles/buttons.
    Future<void> openDrawer() async {
      final scaffoldState =
          tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
    }

    Finder inDrawer(String label) =>
        find.descendant(of: find.byType(Drawer), matching: find.text(label));

    await openDrawer();
    for (final label in const [
      'Home',
      'Crop profiles',
      'Live monitoring',
      'Manual control',
      'Session',
      'Settings & calibration',
    ]) {
      expect(inDrawer(label), findsOneWidget, reason: 'missing $label');
    }

    // Walk to each spec page; a clean pump proves each renders offline.
    for (final label in const [
      'Crop profiles',
      'Live monitoring',
      'Manual control',
      'Session',
      'Settings & calibration',
      'Home',
    ]) {
      await openDrawer();
      await tester.tap(inDrawer(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'error on $label');
    }
  });
}


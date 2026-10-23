import 'package:eco_sus_rural/features/dashboard/screens/main_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Rural Intelligence remains the rightmost dashboard tab',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (_, __) => const MaterialApp(home: MainDashboardScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final destinations = tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .destinations
        .cast<NavigationDestination>();
    expect(destinations[3].icon, isA<Icon>());
    expect((destinations[3].icon as Icon).icon, Icons.person_outline);
    expect(destinations[4].icon, isA<Icon>());
    expect((destinations[4].icon as Icon).icon, Icons.smart_toy_outlined);

    await tester.tap(find.byIcon(Icons.smart_toy_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Rural Intelligence'), findsOneWidget);
  });

  for (final size in [
    const Size(390, 844),
    const Size(800, 600),
    const Size(844, 390)
  ]) {
    for (final textScale in [1.0, 1.5]) {
      testWidgets('dashboard fits $size with text scale $textScale',
          (tester) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          ProviderScope(
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              builder: (_, __) => MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: child!,
                ),
                home: const MainDashboardScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final title = find.text('High Yield Crops Techniques');
        await tester.ensureVisible(title);
        await tester.pumpAndSettle();
        expect(title.hitTestable(), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

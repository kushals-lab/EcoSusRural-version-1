// Regression tests for the reported UI issues:
//
//   * the competitions filter chips (All / Upcoming / Ongoing / Closed) were
//     clipped at the bottom of the screen,
//   * "Set Reminder" now turns into a ticked "Reminder set" mark,
//   * location consent is a required, four-option choice for Weather
//     Intelligence (allow every time / only while using the app / ask every
//     time / deny) and denying never blocks the page,
//   * the 7-day forecast strip no longer overflows at the bottom,
//   * "View mandi impact" opens the charted mandi outlook, and
//   * "Set alert" opens the "Alarm set successfully" confirmation screen.
import 'package:eco_sus_rural/core/permission/location_permission.dart';
import 'package:eco_sus_rural/features/competitions/screens/competitions_screen.dart';
import 'package:eco_sus_rural/features/weather/models/weather_day.dart';
import 'package:eco_sus_rural/features/weather/screens/mandi_impact_screen.dart';
import 'package:eco_sus_rural/features/weather/screens/weather_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [home] at a fixed device size with an optional text scale.
Future<void> _pumpScreen(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, __) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Marks the location answer so feature screens do not show the consent sheet.
void _grantLocation(String mode) {
  SharedPreferences.setMockInitialValues(<String, Object>{
    LocationPermissionStore.prefsKey: mode,
  });
  LocationPermissionStore.reset();
}

void main() {
  setUp(LocationPermissionStore.reset);

  testWidgets('competition status filters stay fully visible', (tester) async {
    for (final size in [const Size(390, 844), const Size(320, 640)]) {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await _pumpScreen(tester, const CompetitionsScreen(), size: size);

      // The first chips are rendered without scrolling and must be complete
      // (not clipped) and inside the viewport.
      for (final label in ['All', 'Upcoming']) {
        final chip = find.widgetWithText(ChoiceChip, label);
        expect(chip, findsOneWidget, reason: '$label chip is missing');
        final rect = tester.getRect(chip);
        expect(rect.height, greaterThan(24),
            reason: '$label chip is clipped vertically');
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.bottom, lessThanOrEqualTo(size.height),
            reason: '$label chip extends past the bottom of the screen');
      }

      // Every chip that is built must sit completely inside the viewport.
      final builtChips = find.byType(ChoiceChip);
      final count = builtChips.evaluate().length;
      expect(count, greaterThanOrEqualTo(2));
      for (var i = 0; i < count; i++) {
        final rect = tester.getRect(builtChips.at(i));
        expect(rect.height, greaterThan(24));
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.bottom, lessThanOrEqualTo(size.height));
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the Last status filter renders fully when scrolled into view', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _pumpScreen(tester, const CompetitionsScreen());

    final lastChip = find.widgetWithText(ChoiceChip, 'Closed');
    await tester.scrollUntilVisible(
      lastChip,
      60,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final rect = tester.getRect(lastChip);
    expect(rect.height, greaterThan(24));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(844));
    expect(rect.right, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);
  });

  testWidgets('competitions screen survives large text scales', (tester) async {
    for (final textScale in [1.0, 1.5]) {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await _pumpScreen(
        tester,
        const CompetitionsScreen(),
        textScale: textScale,
      );
      expect(find.text('All'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Set Reminder becomes a ticked reminder mark', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _pumpScreen(tester, const CompetitionsScreen());

    final setReminder = find.text('Set Reminder');
    expect(setReminder, findsWidgets);
    await tester.ensureVisible(setReminder.first);
    await tester.pumpAndSettle();
    await tester.tap(setReminder.first);
    await tester.pumpAndSettle();

    // The button is replaced by the ticked "Reminder set" badge.
    expect(find.text('Reminder set'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsWidgets);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('ecosus.competitions.reminders'), isNotEmpty);

    // Let the confirmation snack bar expire before the test ends.
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('location consent offers the four platform choices', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    LocationPermissionStore.reset();

    await _pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showLocationPermissionSheet(context),
              child: const Text('Ask location'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ask location'));
    await tester.pumpAndSettle();

    expect(find.text('Allow every time'), findsOneWidget);
    expect(find.text('Only while using the app'), findsOneWidget);
    expect(find.text('Ask every time'), findsOneWidget);
    expect(find.text('Deny'), findsOneWidget);
    expect(find.text('Needed for Weather Intelligence'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Only while using the app'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Only while using the app'));
    await tester.pumpAndSettle();

    expect(LocationPermissionStore.allowsAccess, isTrue);
    expect(LocationPermissionStore.shouldAsk, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(LocationPermissionStore.prefsKey),
      LocationAccessMode.allowWhileUsingApp.name,
    );
  });

  testWidgets('weather intelligence asks for location when never asked', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    LocationPermissionStore.reset();

    await _pumpScreen(tester, const WeatherScreen());
    await tester.pumpAndSettle();

    expect(find.text('Allow every time'), findsOneWidget);
    expect(find.text('Deny'), findsOneWidget);

    await tester.tap(find.text('Deny'));
    await tester.pumpAndSettle();

    // Denying is honoured: the page still works on the village anchor.
    expect(find.text('Location access is off'), findsOneWidget);
    expect(find.text('7-Day Forecast'), findsOneWidget);
    expect(find.text('Weather – Yield Correlation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('7-day forecast renders without bottom overflow', (tester) async {
    for (final textScale in [1.0, 1.3, 1.6]) {
      _grantLocation(LocationAccessMode.allowEveryTime.name);
      await _pumpScreen(tester, const WeatherScreen(), textScale: textScale);

      expect(find.text('7-Day Forecast'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byType(ListView), findsWidgets);
      expect(tester.takeException(), isNull,
          reason: 'forecast strip overflowed at text scale $textScale');
    }
  });

  testWidgets('Set alert opens the alarm-set confirmation screen', (
    tester,
  ) async {
    _grantLocation(LocationAccessMode.allowEveryTime.name);
    await _pumpScreen(tester, const WeatherScreen());

    final setAlert = find.text('Set alert');
    await tester.ensureVisible(setAlert);
    await tester.pumpAndSettle();
    await tester.tap(setAlert);
    await tester.pumpAndSettle();

    expect(find.text('Alarm set successfully'), findsOneWidget);
    expect(find.text('Weather Alert'), findsOneWidget);
    expect(find.text('What you will be alerted about'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Weather Intelligence'), findsOneWidget);
  });

  testWidgets('View mandi impact opens the charted mandi outlook', (
    tester,
  ) async {
    _grantLocation(LocationAccessMode.allowEveryTime.name);
    await _pumpScreen(tester, const WeatherScreen());

    final mandi = find.text('View mandi impact');
    await tester.ensureVisible(mandi);
    await tester.pumpAndSettle();
    await tester.tap(mandi);
    await tester.pumpAndSettle();

    expect(find.text('Mandi Impact Forecast'), findsOneWidget);
    expect(find.text('Projected mandi arrivals (next 7 days)'), findsOneWidget);
    expect(find.text('Future demand vs last season'), findsOneWidget);
    expect(find.text('Crop-wise mandi outlook'), findsOneWidget);
    // Both charts are custom-painted.
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('Normal day'), findsOneWidget);
    expect(find.text('Last season (actual)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mandi impact charts paint for an empty forecast too', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _pumpScreen(
      tester,
      const MandiImpactScreen(forecast: <WeatherDay>[]),
    );

    expect(find.text('Mandi Impact Forecast'), findsOneWidget);
    expect(find.text('No forecast available to project mandi arrivals.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
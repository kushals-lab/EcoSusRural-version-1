import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_sus_rural/features/marketplace/screens/dried_fruit_unit_page.dart';
import 'package:eco_sus_rural/features/marketplace/screens/storage_lab_page.dart';
import 'package:eco_sus_rural/features/marketplace/screens/spice_lab_page.dart';
import 'package:eco_sus_rural/features/marketplace/screens/organic_input_page.dart';
import 'package:eco_sus_rural/features/marketplace/screens/master_farmer_page.dart';
import 'package:eco_sus_rural/features/clock/clock_screen.dart';
import 'package:eco_sus_rural/features/weather/screens/location_selection_screen.dart';

void main() {
  final screens = <Widget>[const DriedFruitUnitPage(), const StorageLabPage(), const SpiceLabPage(),
    const OrganicInputPage(), const MasterFarmerPage(), const LocationSelectionScreen(), const ClockScreen()];
  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    for (final scale in [1.0, 2.0]) {
      for (final screen in screens) {
        testWidgets('${screen.runtimeType} $size text $scale', (tester) async {
          SharedPreferences.setMockInitialValues({});
          tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(ProviderScope(child: ScreenUtilInit(designSize: const Size(390,844),
            builder: (_, __) => MaterialApp(builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!), home: screen))));
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
          final list = find.byType(Scrollable);
          if (list.evaluate().isNotEmpty) {
            for (var i = 0; i < 12; i++) {
              await tester.drag(list.first, const Offset(0,-350)); await tester.pump(const Duration(milliseconds: 100));
              expect(tester.takeException(), isNull);
            }
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        });
      }
    }
  }
}

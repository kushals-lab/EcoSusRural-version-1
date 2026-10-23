// Temporary probe: measures actual render sizes on the legal screen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eco_sus_rural/features/legal/screens/legal_agreement_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

    testWidgets('legal probe: measure checkbox row heights', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (_, __) => const MaterialApp(home: LegalAgreementScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final rows = find.byType(Row);
    debugPrint('checkbox rows found: ${rows.evaluate().length}');
    for (final Element el in rows.evaluate()) {
      final RenderBox rb = el.renderObject! as RenderBox;
      debugPrint('Row size: ${rb.size}');
    }
    final tiles = find.byType(ListTile);
    debugPrint('ListTiles: ${tiles.evaluate().length}');
    for (final Element el in tiles.evaluate()) {
      final RenderBox rb = el.renderObject! as RenderBox;
      debugPrint('ListTile size: ${rb.size}');
    }
    // First text inside a row, to see the effective text scale.
    final texts = find.byType(Text);
    debugPrint('Text widgets: ${texts.evaluate().length}');
    for (final Element el in texts.evaluate().take(6)) {
      final Text t = el.widget as Text;
      final RenderBox rb = el.renderObject! as RenderBox;
      debugPrint('Text "${t.data}" scaled size: ${rb.size}');
    }
  });
}

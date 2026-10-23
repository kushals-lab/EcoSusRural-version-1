import 'package:eco_sus_rural/features/rural_ai/screens/rural_intelligence_screen.dart';
import 'package:eco_sus_rural/features/rural_ai/providers/rural_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('search screen renders and submits a query', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RuralIntelligenceScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rural Intelligence'), findsOneWidget);
    expect(find.text('Ask the Rural Intelligence engine'), findsWidgets);
    expect(find.text('Weather'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'What were rainfall patterns?',
    );
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(container.read(ruralSearchProvider).hasResults, isTrue);
    expect(
        container.read(ruralSearchProvider).answer?.text, contains('weather'));
    expect(
      find.textContaining('EcoSusRural Rural Intelligence - weather'),
      findsOneWidget,
    );
  });
}

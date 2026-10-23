import 'package:eco_sus_rural/core/localization/framework_localizations.dart';
import 'package:eco_sus_rural/core/localization/language_provider.dart';
import 'package:eco_sus_rural/features/language/models/language_model.dart';
import 'package:eco_sus_rural/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('desktop gateway keeps localizations during language changes',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1265, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({'selected_language': 'raj'});
    await tester.pumpWidget(const ProviderScope(child: EcoSusRuralApp()));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    for (final code in ['raj', 'hi', 'en', 'ar', 'raj']) {
      await tester.runAsync(
        () => container.read(languageProvider.notifier).changeLanguage(code),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: code);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.byType(AppBar), findsOneWidget);
      for (final element in [
        tester.element(find.byType(TextField)),
        ...tester.elementList(find.byType(ChoiceChip)),
        tester.element(find.byType(AppBar)),
      ]) {
        expect(Localizations.localeOf(element), Locale(code));
        expect(MaterialLocalizations.of(element).okButtonLabel, isNotEmpty);
      }
    }
  });

  testWidgets('framework delegates load for every registered app language', (
    tester,
  ) async {
    for (final language in kSupportedLanguages) {
      final locale = Locale(language.code);
      late BuildContext localizedContext;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: [locale],
          localizationsDelegates: appLocalizationsDelegates,
          home: Builder(
            builder: (context) {
              localizedContext = context;
              return const Scaffold(body: TextField());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: language.code);
      expect(Localizations.localeOf(localizedContext), locale);
      expect(
          MaterialLocalizations.of(localizedContext).okButtonLabel, isNotEmpty);
      expect(CupertinoLocalizations.of(localizedContext).copyButtonLabel,
          isNotEmpty);
      final rtl = {'ar', 'he', 'ur', 'ks', 'sd', 'syr'}.contains(language.code);
      expect(
        Directionality.of(localizedContext),
        rtl ? TextDirection.rtl : TextDirection.ltr,
        reason: language.code,
      );
    }
  });

  testWidgets('saved Rajasthani stays selected without delegate warnings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'raj'});
    await tester.pumpWidget(const ProviderScope(child: EcoSusRuralApp()));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(context), const Locale('raj'));
    expect(
        ProviderScope.containerOf(context).read(languageProvider).code, 'raj');
    expect(MaterialLocalizations.of(context).okButtonLabel, 'OK');
    expect(CupertinoLocalizations.of(context).copyButtonLabel, 'Copy');
    expect(tester.takeException(), isNull);
  });
}

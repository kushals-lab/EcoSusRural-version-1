import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Framework controls may not have translations for every app language.
/// Keep the app locale (and its JSON translation pack) unchanged, but load
/// English framework strings when Flutter has no translation. Preserve RTL
/// for the registry's Arabic-script languages and map its Traditional Chinese
/// alias to Flutter's script-aware locale.
Locale _frameworkFallback(Locale locale) {
  if (locale.languageCode == 'zht') {
    return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
  }
  if (const {'ks', 'sd', 'syr'}.contains(locale.languageCode)) {
    return const Locale('ur');
  }
  return const Locale('en');
}

class _FrameworkDelegate<T> extends LocalizationsDelegate<T> {
  const _FrameworkDelegate(this.delegate);

  final LocalizationsDelegate<T> delegate;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<T> load(Locale locale) => delegate.load(
        delegate.isSupported(locale) ? locale : _frameworkFallback(locale),
      );

  @override
  bool shouldReload(_FrameworkDelegate<T> old) => false;
}

const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  _FrameworkDelegate<MaterialLocalizations>(
      GlobalMaterialLocalizations.delegate),
  _FrameworkDelegate<WidgetsLocalizations>(GlobalWidgetsLocalizations.delegate),
  _FrameworkDelegate<CupertinoLocalizations>(
      GlobalCupertinoLocalizations.delegate),
];

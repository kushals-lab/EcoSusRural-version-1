import 'core/network/api_client.dart';
import 'core/storage/offline_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/localization/framework_localizations.dart';

import 'core/security/drm_services.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/language_provider.dart';
import 'core/di/injection.dart';
import 'features/language/models/language_model.dart';
import 'features/language/screens/language_gateway_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Show the first frame immediately; storage + DRM settle in the
  // background so cold start never awaits plugins before runApp.
  // ignore: discarded_futures
  DependencyInjection.init();
  // ignore: discarded_futures
  DrmService.secureScreen();

  runApp(const ProviderScope(child: EcoSusRuralApp()));
}

class EcoSusRuralApp extends ConsumerStatefulWidget {
  const EcoSusRuralApp({super.key});

  @override
  ConsumerState<EcoSusRuralApp> createState() => _EcoSusRuralAppState();
}

class _EcoSusRuralAppState extends ConsumerState<EcoSusRuralApp> {
  static final List<Locale> _supportedLocales = kSupportedLanguages
      .map((language) => Locale(language.code))
      .toSet()
      .toList();

  @override
  void initState() {
    super.initState();
    // Load the user's saved language (if any) before the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(languageProvider.notifier).loadSavedLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(networkStatusProvider, (previous, next) { if (next.isOnline && previous?.isOnline != true) OfflineWorkspace.sync(); });
    final languageCode = ref.watch(languageProvider.select((s) => s.code));
    final supportedLocales = _supportedLocales;

    // ScreenUtilInit rebuilds its inherited widget whenever designSize
    // changes, which on desktop resizes re-lays-out all 2,500+ .w/.h lookups.
    // The design width only has two states (phone vs clamped tablet), so keep
    // the last one and reuse it while the window stays in the same bucket.
    return LayoutBuilder(
      builder: (context, constraints) {
        // For large screens (TV/Laptop), clamp the max width to 600px so it feels like a tablet.
        // We calculate a dynamic designWidth so that flutter_screenutil scales .w values
        // to fit perfectly inside the 600px box, avoiding massive UI elements and overflows.
        const double maxAppWidth = 600.0;
        final bool isWide = constraints.maxWidth > maxAppWidth;
        final double designWidth =
            isWide ? constraints.maxWidth * (390.0 / maxAppWidth) : 390.0;

        return Container(
          color: Colors.black87, // Background color for the empty space on TVs/Laptops
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxAppWidth),
              child: ScreenUtilInit(
                designSize: Size(designWidth, 844),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return MaterialApp(
                    title: 'EcoSusRural',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    locale: Locale(languageCode),
                    supportedLocales: supportedLocales,
                    localeResolutionCallback: (locale, supportedLocales) {
                      if (locale == null) return const Locale('en');
                      for (final supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode == locale.languageCode) {
                          return supportedLocale;
                        }
                      }
                      return const Locale('en');
                    },
                    localizationsDelegates: appLocalizationsDelegates,
                    home: const LanguageGatewayScreen(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

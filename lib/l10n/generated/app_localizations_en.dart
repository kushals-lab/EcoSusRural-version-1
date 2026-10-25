// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get offlineLibraryDrafts => 'Offline library & product drafts';

  @override
  String get locationPreferences => 'Location preferences';

  @override
  String get remindersClock => 'Reminders, alarms, timer and world clock';

  @override
  String currentActive(String language) {
    return 'Current active: $language';
  }

  @override
  String get notificationsAlerts => 'Notifications & real-time alerts';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get lowDataMode => 'Low data mode';

  @override
  String get highContrast => 'High contrast & large text';

  @override
  String get biometricQuickLogin => 'Biometric quick login';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsConditions => 'Terms & conditions';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get logoutAction => 'Log out';

  @override
  String get localRecordNotSubmitted =>
      'Local record — not officially submitted';
}

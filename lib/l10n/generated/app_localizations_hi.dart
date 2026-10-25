// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get offlineLibraryDrafts => 'ऑफ़लाइन लाइब्रेरी और उत्पाद ड्राफ़्ट';

  @override
  String get locationPreferences => 'स्थान संबंधी प्राथमिकताएँ';

  @override
  String get remindersClock => 'रिमाइंडर, अलार्म, टाइमर और विश्व घड़ी';

  @override
  String currentActive(String language) {
    return 'वर्तमान भाषा: $language';
  }

  @override
  String get notificationsAlerts => 'सूचनाएँ और ताज़ा अलर्ट';

  @override
  String get pushNotifications => 'पुश सूचनाएँ';

  @override
  String get lowDataMode => 'कम डेटा मोड';

  @override
  String get highContrast => 'अधिक कंट्रास्ट और बड़ा पाठ';

  @override
  String get biometricQuickLogin => 'बायोमेट्रिक लॉग इन';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get termsConditions => 'नियम और शर्तें';

  @override
  String get checkUpdates => 'अपडेट देखें';

  @override
  String get logoutAction => 'लॉग आउट';

  @override
  String get localRecordNotSubmitted =>
      'स्थानीय रिकॉर्ड — आधिकारिक रूप से जमा नहीं';
}

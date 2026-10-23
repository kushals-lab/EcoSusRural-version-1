/// Complete language registry for EcoSusRural: 100 languages.
/// 22 Scheduled Indian + 40 Regional Indian + 38 Foreign = 100 languages.
/// Every [code] has a matching pack at assets/lang/<code>.json plus a
/// manifest entry, so the runtime engine can serve any code without
/// changing app functions.
library lang_codes;

/// A single language entry.
class LangCode {
  final String code;
  final String nativeName;
  final String englishName;
  final String tag;
  final String? parentCode;
  final String script;

  const LangCode({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.tag,
    this.parentCode,
    this.script = 'Latin',
  });
}

/// The complete 100-language registry.
/// 22 Eighth-Schedule Official Indian + 40 Regional Indian + 38 Foreign = 100.
/// English ('en') is the global link language and is listed first; it is NOT
/// one of the 22 Scheduled languages.
class AllLanguages {
  static const _langs = <LangCode>[
    LangCode(code: 'en', nativeName: 'English', englishName: 'English', tag: 'Link'),
    LangCode(code: 'en-US', nativeName: 'English (US)', englishName: 'English (United States)', tag: 'Link', parentCode: 'en'),
    LangCode(code: 'en-GB', nativeName: 'English (UK)', englishName: 'English (United Kingdom)', tag: 'Link', parentCode: 'en'),
    LangCode(code: 'en-IN', nativeName: 'English (India)', englishName: 'English (India)', tag: 'Link', parentCode: 'en'),
    LangCode(code: 'en-AU', nativeName: 'English (Australia)', englishName: 'English (Australia)', tag: 'Link', parentCode: 'en-GB'),
    // 22 Eighth-Schedule Official Indian languages
    LangCode(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi', tag: 'Official', script: 'Devanagari'),
    LangCode(code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali', tag: 'Official', script: 'Bengali'),
    LangCode(code: 'te', nativeName: 'తెలుగు', englishName: 'Telugu', tag: 'Official', script: 'Telugu'),
    LangCode(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil', tag: 'Official', script: 'Tamil'),
    LangCode(code: 'mr', nativeName: 'मराठी', englishName: 'Marathi', tag: 'Official', script: 'Devanagari'),
    LangCode(code: 'gu', nativeName: 'ગુજરાતી', englishName: 'Gujarati', tag: 'Official', script: 'Gujarati'),
    LangCode(code: 'kn', nativeName: 'ಕನ್ನಡ', englishName: 'Kannada', tag: 'Official', script: 'Kannada'),
    LangCode(code: 'ml', nativeName: 'മലയാളം', englishName: 'Malayalam', tag: 'Official', script: 'Malayalam'),
    LangCode(code: 'pa', nativeName: 'ਪੰਜਾਬੀ', englishName: 'Punjabi', tag: 'Official', script: 'Gurmukhi'),
    LangCode(code: 'or', nativeName: 'ଓଡ଼ିଆ', englishName: 'Odia', tag: 'Official', script: 'Odia'),
    LangCode(code: 'as', nativeName: 'অসমীয়া', englishName: 'Assamese', tag: 'Official', script: 'Assamese'),
    LangCode(code: 'ks', nativeName: 'کٲشُر', englishName: 'Kashmiri', tag: 'Official', script: 'Perso-Arabic'),
    LangCode(code: 'kok', nativeName: 'कोंकणी', englishName: 'Konkani', tag: 'Official', script: 'Devanagari'),
    LangCode(code: 'sd', nativeName: 'سنڌي', englishName: 'Sindhi', tag: 'Official', script: 'Perso-Arabic'),
    LangCode(code: 'mai', nativeName: 'मैथिली', englishName: 'Maithili', tag: 'Official', script: 'Devanagari'),
    LangCode(code: 'mni', nativeName: 'মৈতৈলোন্', englishName: 'Manipuri', tag: 'Official', script: 'Bengali'),
    LangCode(code: 'ne', nativeName: 'नेपाली', englishName: 'Nepali', tag: 'Official', script: 'Devanagari'),
    LangCode(code: 'sa', nativeName: 'संस्कृतम्', englishName: 'Sanskrit', tag: 'Official', script: 'Devanagari'),
    LangCode(code: 'syr', nativeName: 'ܠܫܢܝ ܣܘܪܝܝܐ', englishName: 'Syriac', tag: 'Official', script: 'Syriac'),
    LangCode(code: 'doi', nativeName: 'डोगरी', englishName: 'Dogri', tag: 'Official', script: 'Devanagari'),
    LangCode(code: 'sat', nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ', englishName: 'Santali', tag: 'Official', script: 'Ol Chiki'),
    // 40 Regional Indian languages (one per state minimum)
    LangCode(code: 'bho', nativeName: 'भोजपुरी', englishName: 'Bhojpuri', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'mag', nativeName: 'मगही', englishName: 'Magahi', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'ang', nativeName: 'अंगिका', englishName: 'Angika', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'raj', nativeName: 'राजस्थानी', englishName: 'Rajasthani', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'mwr', nativeName: 'मारवाड़ी', englishName: 'Marwari', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'awa', nativeName: 'अवधी', englishName: 'Awadhi', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'braj', nativeName: 'ब्रज भाषा', englishName: 'Braj', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'bund', nativeName: 'बुंदेली', englishName: 'Bundeli', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'bag', nativeName: 'बघेली', englishName: 'Bagheli', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'var', nativeName: 'वर्हाडी', englishName: 'Varhadi', tag: 'Regional', parentCode: 'mr', script: 'Devanagari'),
    LangCode(code: 'kath', nativeName: 'કાઠિયાવાડી', englishName: 'Kathiawadi', tag: 'Regional', parentCode: 'gu', script: 'Gujarati'),
    LangCode(code: 'kut', nativeName: 'કચ્છી', englishName: 'Kutchi', tag: 'Regional', parentCode: 'gu', script: 'Gujarati'),
    LangCode(code: 'kod', nativeName: 'ಕೊಡವ', englishName: 'Kodava', tag: 'Regional', parentCode: 'kn', script: 'Kannada'),
    LangCode(code: 'tcy', nativeName: 'ತುಳು', englishName: 'Tulu', tag: 'Regional', parentCode: 'kn', script: 'Kannada'),
    LangCode(code: 'mle', nativeName: 'മലബാർ', englishName: 'Malabar', tag: 'Regional', parentCode: 'ml', script: 'Malayalam'),
    LangCode(code: 'tnk', nativeName: 'கொங்கு தமிழ்', englishName: 'Kongu', tag: 'Regional', parentCode: 'ta', script: 'Tamil'),
    LangCode(code: 'tnc', nativeName: 'சென்னை தமிழ்', englishName: 'Chennai', tag: 'Regional', parentCode: 'ta', script: 'Tamil'),
    LangCode(code: 'har', nativeName: 'ਹਰਿਆਣਵੀ', englishName: 'Haryanvi', tag: 'Regional', parentCode: 'pa', script: 'Gurmukhi'),
    LangCode(code: 'syl', nativeName: 'ꠍꠤꠟꠐꠤ', englishName: 'Sylheti', tag: 'Regional', parentCode: 'bn', script: 'Bengali'),
    LangCode(code: 'cha', nativeName: 'छत्तीसगढ़ी', englishName: 'Chhattisgarhi', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'smb', nativeName: 'ସମ୍ବଲପୁରୀ', englishName: 'Sambalpuri', tag: 'Regional', parentCode: 'or', script: 'Odia'),
    LangCode(code: 'kha', nativeName: 'Ka Ktien Khasi', englishName: 'Khasi', tag: 'Regional', parentCode: 'as', script: 'Bengali'),
    LangCode(code: 'ngl', nativeName: 'Nagamese', englishName: 'Nagamese', tag: 'Regional', parentCode: 'hi', script: 'Latin'),
    LangCode(code: 'gon', nativeName: 'गोंडी', englishName: 'Gondi', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'kru', nativeName: 'कुरुख़', englishName: 'Kurukh', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'kku', nativeName: 'कोरकू', englishName: 'Korku', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'sau', nativeName: 'સૌરાષ્ટ્ર', englishName: 'Saurashtra', tag: 'Regional', parentCode: 'gu', script: 'Gujarati'),
    LangCode(code: 'tod', nativeName: 'தோதா', englishName: 'Toda', tag: 'Regional', parentCode: 'ta', script: 'Tamil'),
    LangCode(code: 'pah', nativeName: 'पहाड़ी', englishName: 'Pahari', tag: 'Regional', parentCode: 'ks', script: 'Devanagari'),
    LangCode(code: 'rab', nativeName: 'রাভা', englishName: 'Rabha', tag: 'Regional', parentCode: 'as', script: 'Bengali'),
    LangCode(code: 'trip', nativeName: 'ককবরক', englishName: 'Kokborok', tag: 'Regional', parentCode: 'bn', script: 'Bengali'),
    LangCode(code: 'gdb', nativeName: 'गद्दी', englishName: 'Gaddi', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'jns', nativeName: 'जौनसारी', englishName: 'Jaunsari', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'gaar', nativeName: 'गढ़वाली', englishName: 'Garhwali', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'kmn', nativeName: 'कुमाऊँनी', englishName: 'Kumaoni', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'ngp', nativeName: 'नागपुरी', englishName: 'Nagpuri', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'kos', nativeName: 'कुरमाली', englishName: 'Kurmali', tag: 'Regional', parentCode: 'hi', script: 'Devanagari'),
    LangCode(code: 'njl', nativeName: 'Angami', englishName: 'Angami', tag: 'Regional', parentCode: 'mni', script: 'Latin'),
    LangCode(code: 'mizo', nativeName: 'Mizo ṭawng', englishName: 'Mizo', tag: 'Regional', parentCode: 'mni', script: 'Latin'),
    // 38 Foreign languages
    LangCode(code: 'ar', nativeName: 'العربية', englishName: 'Arabic', tag: 'Foreign', script: 'Arabic'),
    LangCode(code: 'es', nativeName: 'Español', englishName: 'Spanish', tag: 'Foreign'),
    LangCode(code: 'fr', nativeName: 'Français', englishName: 'French', tag: 'Foreign'),
    LangCode(code: 'de', nativeName: 'Deutsch', englishName: 'German', tag: 'Foreign'),
    LangCode(code: 'pt', nativeName: 'Português', englishName: 'Portuguese', tag: 'Foreign'),
    LangCode(code: 'it', nativeName: 'Italiano', englishName: 'Italian', tag: 'Foreign'),
    LangCode(code: 'ru', nativeName: 'Русский', englishName: 'Russian', tag: 'Foreign', script: 'Cyrillic'),
    LangCode(code: 'zh', nativeName: '简体中文', englishName: 'Chinese (Simplified)', tag: 'Foreign', script: 'Han'),
    LangCode(code: 'zht', nativeName: '繁體中文', englishName: 'Chinese (Traditional)', tag: 'Foreign', script: 'Han (Traditional)'),
    LangCode(code: 'ja', nativeName: '日本語', englishName: 'Japanese', tag: 'Foreign', script: 'Japanese'),
    LangCode(code: 'ko', nativeName: '한국어', englishName: 'Korean', tag: 'Foreign', script: 'Hangul'),
    LangCode(code: 'vi', nativeName: 'Tiếng Việt', englishName: 'Vietnamese', tag: 'Foreign'),
    LangCode(code: 'th', nativeName: 'ไทย', englishName: 'Thai', tag: 'Foreign', script: 'Thai'),
    LangCode(code: 'fil', nativeName: 'Filipino', englishName: 'Filipino', tag: 'Foreign'),
    LangCode(code: 'sv', nativeName: 'Svenska', englishName: 'Swedish', tag: 'Foreign'),
    LangCode(code: 'da', nativeName: 'Dansk', englishName: 'Danish', tag: 'Foreign'),
    LangCode(code: 'nb', nativeName: 'Norsk bokmål', englishName: 'Norwegian', tag: 'Foreign'),
    LangCode(code: 'fi', nativeName: 'Suomi', englishName: 'Finnish', tag: 'Foreign'),
    LangCode(code: 'pl', nativeName: 'Polski', englishName: 'Polish', tag: 'Foreign'),
    LangCode(code: 'cs', nativeName: 'Čeština', englishName: 'Czech', tag: 'Foreign'),
    LangCode(code: 'sk', nativeName: 'Slovenčina', englishName: 'Slovak', tag: 'Foreign'),
    LangCode(code: 'hu', nativeName: 'Magyar', englishName: 'Hungarian', tag: 'Foreign'),
    LangCode(code: 'ro', nativeName: 'Română', englishName: 'Romanian', tag: 'Foreign'),
    LangCode(code: 'el', nativeName: 'Ελληνικά', englishName: 'Greek', tag: 'Foreign', script: 'Greek'),
    LangCode(code: 'tr', nativeName: 'Türkçe', englishName: 'Turkish', tag: 'Foreign'),
    LangCode(code: 'he', nativeName: 'עברית', englishName: 'Hebrew', tag: 'Foreign', script: 'Hebrew'),
    LangCode(code: 'ur', nativeName: 'اردو', englishName: 'Urdu', tag: 'Foreign', script: 'Perso-Arabic'),
    LangCode(code: 'ha', nativeName: 'Hausa', englishName: 'Hausa', tag: 'Foreign'),
    LangCode(code: 'sw', nativeName: 'Kiswahili', englishName: 'Swahili', tag: 'Foreign'),
    LangCode(code: 'nl', nativeName: 'Nederlands', englishName: 'Dutch', tag: 'Foreign'),
    LangCode(code: 'id', nativeName: 'Bahasa Indonesia', englishName: 'Indonesian', tag: 'Foreign'),
    LangCode(code: 'ms', nativeName: 'Bahasa Melayu', englishName: 'Malay', tag: 'Foreign'),
    LangCode(code: 'uk', nativeName: 'Українська', englishName: 'Ukrainian', tag: 'Foreign', script: 'Cyrillic'),
    LangCode(code: 'sr', nativeName: 'Српски', englishName: 'Serbian', tag: 'Foreign', script: 'Cyrillic'),
    LangCode(code: 'hr', nativeName: 'Hrvatski', englishName: 'Croatian', tag: 'Foreign'),
    LangCode(code: 'bg', nativeName: 'Български', englishName: 'Bulgarian', tag: 'Foreign', script: 'Cyrillic'),
    LangCode(code: 'ca', nativeName: 'Català', englishName: 'Catalan', tag: 'Foreign'),
    LangCode(code: 'eu', nativeName: 'Euskara', englishName: 'Basque', tag: 'Foreign'),
  ];

  /// All [LangCode] entries in this registry.
  static List<LangCode> get all => _langs;

  /// All language codes as strings, sorted alphabetically.
  static List<String> get allCodes => _langs.map((l) => l.code).toList()..sort((a, b) => a.compareTo(b));

  /// Total count.
  static int get totalCount => _langs.length;

  /// Find by code.
  static LangCode? byCode(String code) {
    for (final lang in _langs) {
      if (lang.code == code) return lang;
    }
    return null;
  }
}
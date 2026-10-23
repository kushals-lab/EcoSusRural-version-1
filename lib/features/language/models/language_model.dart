/// Represents a single language shown in the language selection gateway.
library language_model;

import '../../../core/localization/lang_codes.dart';

class LanguageModel {
  final String code;          // e.g. 'en', 'hi', 'bho'
  final String nativeName;    // e.g. 'हिन्दी', 'বাংলা'
  final String englishName;   // e.g. 'Hindi', 'Bengali'
  final String region;        // 'All' | 'India' | 'World'
  final String sampleSentence;// Sample sentence shown in the confirmation modal
  final bool isForeign;

  const LanguageModel({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.region,
    required this.sampleSentence,
    this.isForeign = false,
  });
}

/// Native-script greeting + welcome line for the confirmation modal.
/// Languages not listed here fall back to the English sample sentence.
const Map<String, String> kSampleSentences = {
  'en': 'Hello! Welcome to EcoSusRural.',
  'en-US': 'Hello! Welcome to EcoSusRural.',
  'en-GB': 'Hello! Welcome to EcoSusRural.',
  'en-IN': 'Namaste & Hello! Welcome to EcoSusRural.',
  'en-AU': 'G\'day! Welcome to EcoSusRural.',
  'hi': 'नमस्ते! EcoSusRural में आपका स्वागत है।',
  'bn': 'নমস্কার! EcoSusRural-এ আপনাকে স্বাগতম।',
  'te': 'నమస్కారం! EcoSusRural కు మీకు స్వాగతం.',
  'mr': 'नमस्कार! EcoSusRural मध्ये तुमचे स्वागत आहे.',
  'ta': 'வணக்கம்! EcoSusRural-க்கு உங்களை வரவேற்கிறோம்.',
  'gu': 'નમસ્તે! EcoSusRural માં આપનું સ્વાગત છે.',
  'kn': 'ನಮಸ್ಕಾರ! EcoSusRural ಗೆ ಸ್ವಾಗತವಿದೆ.',
  'ml': 'നമസ്കാരം! EcoSusRural-ലേക്ക് സ്വാഗതം.',
  'pa': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ! EcoSusRural ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ।',
  'or': 'ନମସ୍କାର! EcoSusRural କୁ ଆପଣଙ୍କୁ ସ୍ୱାଗତ।',
  'as': 'নমস্কাৰ! EcoSusRural-লৈ আপোনাক স্বাগতম।',
  'ur': 'خوش آمدید! EcoSusRural میں آپ کا استقبال ہے۔',
  'kok': 'नमस्कार! EcoSusRural म्हण स्वागत आहे.',
  'mai': 'प्रणाम! EcoSusRural में अहाँक स्वागत अछि।',
  'ne': 'नमस्ते! EcoSusRural मा स्वागत छ।',
  'sa': 'नमस्ते! EcoSusRural इति स्वागतम्।',
  'sd': 'ڀلي ڪري آيا! EcoSusRural ۾ آءُ جي خوش آمدید.',
  'ks': 'خوش آمدی! EcoSusRural منز کُوں بہخوش آمدید۔',
  'mni': 'চৌমথোক! EcoSusRural-দা চানখিৱদে।',
  'sat': 'ᱡᱩᱦᱟᱹᱨ! EcoSusRural ᱥᱮᱫ ᱥᱟᱨᱦᱟᱣ ᱢᱮ।',
  'doi': 'नमस्कार! EcoSusRural रा स्वागत।',
  'syr': 'ܫܠܡܐ! ܒܝܬ EcoSusRural ܒܪܟܐ.',
  'bho': 'प्रणाम! EcoSusRural में रउआ के स्वागत बा।',
  'raj': 'पद्मारो! EcoSusRural मां रावणो स्वागत छै।',
  'mwr': 'पद्मारो! EcoSusRural म्हे थकुण स्वागत छै।',
  'awa': 'प्रणाम! EcoSusRural में आप के स्वागत है।',
  'braj': 'प्रणाम! EcoSusRural मैं आपका स्वागत छै।',
  'mag': 'प्रणाम! EcoSusRural मे हमरा स्वागत बा।',
  'ang': 'प्रणाम! EcoSusRural में अहाँक स्वागत अछि।',
  'cha': 'नमस्कार! EcoSusRural मा तोहर स्वागत हे।',
  'syl': 'আসসালাম! EcoSusRural-ত আপনাকে স্বাগতম।',
  'smb': 'ନମସ୍କାର! EcoSusRural କୁ ସ୍ୱାଗତ।',
  'har': 'सत श्री अकाल! EcoSusRural में तेरा स्वागत ऐ।',
  'ngl': 'Namaskar! Welcome to EcoSusRural.',
  'gon': 'नमस्कार! EcoSusRural रे स्वागत।',
  'kru': 'नमस्कार! EcoSusRural तहा स्वागत।',
  'kos': 'नमस्कार! EcoSusRural में रउरा स्वागत बा।',
  'gaar': 'नमस्कार! EcoSusRural मा तेरै स्वागत छ।',
  'kmn': 'नमस्कार! EcoSusRural मा तुमार स्वागत छ।',
  'pah': 'नमस्कार! EcoSusRural दा स्वागत है।',
  'kha': 'Khublei! Welcome to EcoSusRural.',
  'mizo': 'Chhibai! EcoSusRural-ah khawmpui a ni.',
  'es': '¡Hola! Bienvenido a EcoSusRural.',
  'fr': 'Bonjour ! Bienvenue sur EcoSusRural.',
  'de': 'Hallo! Willkommen bei EcoSusRural.',
  'ar': 'مرحباً! مرحباً بك في EcoSusRural.',
  'pt': 'Olá! Bem-vindo ao EcoSusRural.',
  'it': 'Ciao! Benvenuto su EcoSusRural.',
  'ru': 'Привет! Добро пожаловать в EcoSusRural.',
  'zh': '你好！欢迎来到 EcoSusRural。',
  'zht': '你好！歡迎來到 EcoSusRural。',
  'ja': 'こんにちは！EcoSusRural へようこそ。',
  'ko': '안녕하세요! EcoSusRural에 오신 것을 환영합니다.',
  'vi': 'Xin chào! Chào mừng đến với EcoSusRural.',
  'th': 'สวัสดี! ยินดีต้อนรับสู่ EcoSusRural',
  'fil': 'Kumusta! Maligayang pagdating sa EcoSusRural.',
  'sv': 'Hej! Välkommen till EcoSusRural.',
  'da': 'Hej! Velkommen til EcoSusRural.',
  'nb': 'Hei! Velkommen til EcoSusRural.',
  'fi': 'Hei! Tervetuloa EcoSusRuraliin.',
  'pl': 'Cześć! Witamy w EcoSusRural.',
  'cs': 'Ahoj! Vítejte v EcoSusRural.',
  'sk': 'Ahoj! Vitajte v EcoSusRural.',
  'hu': 'Helló! Üdvözlünk az EcoSusRural-ban.',
  'ro': 'Bună! Bine ați venit la EcoSusRural.',
  'el': 'Γεια σας! Καλώς ήρθατε στο EcoSusRural.',
  'tr': 'Merhaba! EcoSusRural\'e hoş geldiniz.',
  'he': 'שלום! ברוך הבא ל-EcoSusRural.',
  'ha': 'Sannu! Barka da zuwa EcoSusRural.',
  'sw': 'Habari! Karibu EcoSusRural.',
  'nl': 'Hallo! Welkom bij EcoSusRural.',
  'id': 'Halo! Selamat datang di EcoSusRural.',
  'ms': 'Hai! Selamat datang ke EcoSusRural.',
  'uk': 'Привіт! Ласкаво просимо до EcoSusRural.',
  'sr': 'Здраво! Добродошли у EcoSusRural.',
  'hr': 'Zdravo! Dobrodošli u EcoSusRural.',
  'bg': 'Здравейте! Добре дошли в EcoSusRural.',
  'ca': 'Hola! Benvingut a EcoSusRural.',
  'eu': 'Kaixo! Ongi etorri EcoSusRural-era.',
};

/// All 100 registered languages surfaced in the language selection gateway,
/// generated directly from the canonical registry so the gateway always lists
/// every supported language with its native name.
final List<LanguageModel> kSupportedLanguages = AllLanguages.all
    .map((l) => LanguageModel(
          code: l.code,
          nativeName: l.nativeName,
          englishName: l.englishName,
          region: l.code == 'en'
              ? 'All'
              : (l.tag == 'Foreign' ? 'World' : 'India'),
          sampleSentence:
              kSampleSentences[l.code] ?? kSampleSentences['en']!,
          isForeign: l.tag == 'Foreign',
        ))
    .toList();

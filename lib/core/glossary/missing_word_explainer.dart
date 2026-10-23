/// Word-level missing-terminology explanation system.
/// When a translation key is missing in the user's language, this system
/// provides a short explanation in the user's language at that place,
/// without changing any app functions.
library missing_word_explainer;

import 'package:flutter/material.dart';
import '../translation/translation_repository.dart';

/// Provides explanations for terms that lack translations.
class MissingWordExplainer {
  const MissingWordExplainer._();
  static const MissingWordExplainer instance = MissingWordExplainer._();

  /// Check if a key has a translation in the given language.
  /// Uses the translation repository directly so this file never depends on
  /// the platform localization class (LanguageLocalizations) and stays
  /// usable from non-widget contexts.
  bool hasTranslation(String key, String languageCode) {
    final code = languageCode.trim().toLowerCase();
    final pack = TranslationRepository.instance.snapshot(code);
    if (pack.containsKey(key)) return true;
    final parent = TranslationRepository.instance.parentOf(code);
    if (parent != null) {
      final parentPack = TranslationRepository.instance.snapshot(parent);
      if (parentPack.containsKey(key)) return true;
    }
    final enPack = TranslationRepository.instance.snapshot('en');
    if (enPack.containsKey(key)) return true;
    return false;
  }

  /// Get a short explanation for a missing term in the user's language.
  String explain(String key, String languageCode) {
    final glossary = _glossary[key];
    if (glossary == null) return key;
    return glossary[languageCode] ?? glossary['en'] ?? key;
  }

  /// Show a bottom-sheet explanation for a missing term.
  void showExplanation(BuildContext context, String key, String languageCode) {
    final explanation = explain(key, languageCode);
    final code = languageCode.trim().toLowerCase();
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(explanation),
            const SizedBox(height: 4),
            // Provenance note so the user knows this is an explanation,
            // not a native word — shown in their own selected language.
            Text(
              code == 'en'
                  ? '(Explanation shown because no native word is available.)'
                  : '(No native word available for “$key” — explanation shown.)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }

  /// Inline widget that shows the term with an explanation tooltip.
  Widget buildInline(
    BuildContext context,
    String key,
    String languageCode, {
    TextStyle? style,
  }) {
    bool has = hasTranslation(key, languageCode);
    final code = languageCode.trim().toLowerCase();
    final pack = TranslationRepository.instance.snapshot(code);
    String text = key;
    if (pack.containsKey(key)) {
      text = pack[key]!;
    } else {
      final parent = TranslationRepository.instance.parentOf(code);
      if (parent != null) {
        final parentPack = TranslationRepository.instance.snapshot(parent);
        if (parentPack.containsKey(key)) {
          text = parentPack[key]!;
          has = true;
        }
      }
      if (!has) {
        final enPack = TranslationRepository.instance.snapshot('en');
        text = enPack.containsKey(key) ? enPack[key]! : key;
      }
    }
    if (has) {
      return Text(text, style: style);
    }
    return GestureDetector(
      onTap: () => showExplanation(context, key, languageCode),
      child: Text(
        text,
        style: style?.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ) ??
            const TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ),
      ),
    );
  }

  /// Glossary of terms that may be missing in some languages.
  static const _glossary = <String, Map<String, String>>{
    'marketplace': {
      'en': 'A place where farmers and artisans sell products directly to buyers.',
      'hi': 'किसानों और कारीगरों के लिए सीधे खरीदारों को उत्पाद बेचने का स्थान।',
      'bn': 'কৃষক ও কারিগররা সরাসরি ক্রেতাদের কাছে পণ্য বিক্রি করেন এমন জায়গা।',
      'te': 'రైతులు మరియు శిల్పులు నేరుగా కొనుగోలుదారులకు వస్తువులను అమ్మే ప్రదేశం.',
      'ta': 'விவசாயிகள் மற்றும் கைவினைஞர்கள் நேரடியாக வாங்குபவர்களுக்கு பொருட்களை விற்கும் இடம்.',
      'mr': 'शेतकरी आणि कारागीर थेट खरेदीदारांना उत्पादन विकतात ठिकाण.',
    },
    'subscription': {
      'en': 'A recurring payment plan that gives you benefits for a fixed period.',
      'hi': 'एक आवर्ती भुगतान योजना जो आपको एक निश्चित अवधि के लिए लाभ देती है।',
      'bn': 'একটি পুনরাবৃত্তি পেমেন্ট পরিকল্পনা যা নির্দিষ্ট সময়ের জন্য সুবিধা দেয়।',
      'te': 'నిర్దిష్ట కాలానికి ప్రయోజనాలు ఇచ్చే పునరావృత చెల్లింపు ప్రణాళిక.',
      'ta': 'ஒரு குறிப்பிட்ட காலத்திற்கு நன்மைகளை வழங்கும் திரும்பவரும் கட்டண திட்டம்.',
      'mr': 'निश्चित कालावधीसाठी फायदे देणारा पुनरावृत्ती पेमेंट योजना.',
    },
    'wallet': {
      'en': 'Your digital money storage inside the app for payments and transfers.',
      'hi': 'भुगतान और स्थानांतरण के लिए ऐप के अंदर आपका डिजिटल पैसा भंडारण।',
      'bn': 'পেমেন্ট এবং ট্রান্সফারের জন্য অ্যাপের ভিতরে আপনার ডিজিটাল টাকা সঞ্চয়।',
      'te': 'చెల్లింపులు మరియు బదిలీల కోసం యాప్ లోపల మీ డిజిటల్ డబ్బు నిల్వ.',
      'ta': 'கொடுப்பனவு மற்றும் பரிமாற்றங்களுக்கான செயலியின் உள்ளே உங்கள் டிஜிட்டல் பணச் சேமிப்பு.',
      'mr': 'पेमेंट आणि ट्रान्सफरसाठी अॅपमधील तुमचे डिजिटल पैसे साठवणूक.',
    },
  };
}
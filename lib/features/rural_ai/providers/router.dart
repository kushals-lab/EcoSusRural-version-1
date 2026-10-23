/// Deterministic search router for Rural Intelligence.
///
/// Policy-driven mapping from the user's own words to the correct intelligence
/// module (agriculture / livestock / weather / prices / schemes / marketplace).
/// No model prompt, no lookup table of full questions, no hallucinated routing.
///
/// DEFAULT: single-pass marker scan over the query text.
/// COMPLEX: a stricter embedding match may be added later; the interface stays
/// the same so it can be swapped.
library;

/// Structured evidence returned by the router (Part 12.1).
class SearchEvidence {
  final String intent;
  final String sector;
  final String suggestion;
  final List<String> citations;

  const SearchEvidence({
    required this.intent,
    required this.sector,
    required this.suggestion,
    required this.citations,
  });
}

/// Policy-driven router: maps user words -> intelligence module.
class RuralSearchVerifier {
  RuralSearchVerifier._();

  static const Map<String, Map<String, Object>> _rules = {
    'agriculture': {
      'markers': ['crop', 'farm', 'harvest', 'seed', 'soil', 'cultivate', 'sowing'],
      'intent': 'agriculture_advisory',
      'sector': 'agriculture',
      'suggestion': 'crop_sowing_advisory',
    },
    'livestock': {
      'markers': ['cow', 'buffalo', 'milk', 'poultry', 'goat', 'sheep', 'animal', 'veterinary'],
      'intent': 'livestock_advisory',
      'sector': 'livestock',
      'suggestion': 'livestock_husbandry',
    },
    'weather': {
      'markers': ['rain', 'rainfall', 'weather', 'temperature', 'temp', 'forecast', 'heatwave', 'drought'],
      'intent': 'weather_history',
      'sector': 'weather',
      'suggestion': 'weather_history',
    },
    'prices': {
      'markers': ['price', 'mandi', 'market', 'marketplace', 'arrival', 'wholesale', 'commodity'],
      'intent': 'market_search',
      'sector': 'prices',
      'suggestion': 'commodity_price_trend',
    },
    'schemes': {
      'markers': ['scheme', 'subsidy', 'grant', 'awardId', 'goi scheme', 'eligibility', 'portal'],
      'intent': 'scheme_search',
      'sector': 'schemes',
      'suggestion': 'scheme_lookup',
    },
    'marketplace': {
      'markers': ['product', 'listing', 'buy', 'sell', 'order', 'cart', 'seller'],
      'intent': 'marketplace_search',
      'sector': 'marketplace',
      'suggestion': 'marketplace_search',
    },
  };

  /// Infer the best module from the words in the user's own query.
  static SearchEvidence route(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const SearchEvidence(
        intent: 'general',
        sector: 'general',
        suggestion: 'general_rural_advisory',
        citations: [],
      );
    }

    SearchEvidence best = _default(q);
    int bestScore = -1;

    for (final entry in _rules.entries) {
      final markers = (entry.value['markers'] as List).cast<String>();
      int score = 0;
      for (final m in markers) {
        if (q.contains(m)) {
          score++;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = SearchEvidence(
          intent: entry.value['intent'] as String,
          sector: entry.value['sector'] as String,
          suggestion: entry.value['suggestion'] as String,
          citations: const [],
        );
      }
    }
    return best;
  }

  static SearchEvidence _default(String q) {
    final intent = q.contains('price') || q.contains('market')
        ? 'market_search'
        : (q.contains('crop') || q.contains('farm') ? 'agriculture_advisory' : 'general');
    return SearchEvidence(
      intent: intent,
      sector: intent,
      suggestion: 'general_rural_advisory',
      citations: const [],
    );
  }

  static bool requiresIntent(String intent) =>
      intent == 'agriculture_advisory' ||
      intent == 'livestock_advisory' ||
      intent == 'weather_history' ||
      intent == 'market_search' ||
      intent == 'scheme_search';
}

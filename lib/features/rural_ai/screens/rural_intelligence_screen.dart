/// Rural Intelligence screen (primary AI tab).
/// Screen class with controllers + logic; build body lives in
/// [rural_intelligence_body.dart].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rural_search_provider.dart';
import 'rural_intelligence_body.dart';

class RuralIntelligenceScreen extends ConsumerStatefulWidget {
  const RuralIntelligenceScreen({super.key});

  @override
  ConsumerState<RuralIntelligenceScreen> createState() =>
      _RuralIntelligenceScreenState();
}

class _RuralIntelligenceScreenState
    extends ConsumerState<RuralIntelligenceScreen> {
  void _search(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return;
    }
    ref.read(ruralSearchProvider.notifier).evaluate(trimmedQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: const Text('Rural Intelligence'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B4D3E),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: QuickCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(category.label),
                    onPressed: () {
                      final controller =
                          ref.read(ruralSearchProvider.notifier).controller;
                      controller.text = category.query;
                      _search(category.query);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: ruralIntelligenceBody(context, ref)),
        ],
      ),
    );
  }
}

enum QuickCategory {
  agriculture,
  livestock,
  weather,
  prices,
  schemes,
  marketplace
}

extension QuickCategoryExt on QuickCategory {
  String get label => {
        QuickCategory.agriculture: 'Agriculture',
        QuickCategory.livestock: 'Livestock',
        QuickCategory.weather: 'Weather',
        QuickCategory.prices: 'Prices',
        QuickCategory.schemes: 'Schemes',
        QuickCategory.marketplace: 'Marketplace',
      }[this]!;

  String get query {
    switch (this) {
      case QuickCategory.agriculture:
        return 'farm and crop support';
      case QuickCategory.livestock:
        return 'livestock and animal health';
      case QuickCategory.weather:
        return 'rainfall patterns over the last 20 years';
      case QuickCategory.prices:
        return 'historical mandi prices for my crop';
      case QuickCategory.schemes:
        return 'government schemes available for my district';
      case QuickCategory.marketplace:
        return 'how do I list my product on EcoSusRural';
    }
  }
}

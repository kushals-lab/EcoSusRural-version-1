/// Evidence result card: text + figures + sources, incl. a privacy banner.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/models.dart';
import 'figure_card.dart';

/// Compact privacy/safety banner shown above search results.
class PrivacyBanner extends StatelessWidget {
  final bool featuresWithNoMedia; // True when media analysis is not available.
  const PrivacyBanner({super.key, this.featuresWithNoMedia = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.amber.shade100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              featuresWithNoMedia
                  ? 'Media analysis is not available in this build. Only verified, source-cited statistics and scheme listings are shown. No user media is stored or analysed here.'
                  : 'EcoSusRural Rural Intelligence is an evidence engine, not a chat substitute. Verify agronomic, financial and legal decisions with certified experts. All figures below are reproducible and traceable to the data registry.',
              style: TextStyle(fontSize: 11.sp, color: Colors.amber.shade900, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search-result card with figures + sources.
class RuralResultCard extends StatelessWidget {
  final String text;
  final List<RuralFigure> figures;
  final List<RuralSource> sources;

  const RuralResultCard({
    super.key,
    required this.text,
    required this.figures,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.45),
              maxLines: 24,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (figures.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...figures.map((f) => RuralFigureCard(
              label: f.label,
              value: f.value,
              unit: f.unit,
              period: f.period,
              accent: const Color(0xFF1B4D3E),
            )),
          ],
          if (sources.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...sources.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Source: ${s.title}${s.url.isNotEmpty ? ' (${s.url})' : ''}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], fontStyle: FontStyle.italic),
              ),
            )),
          ],
        ],
      ),
    );
  }
}

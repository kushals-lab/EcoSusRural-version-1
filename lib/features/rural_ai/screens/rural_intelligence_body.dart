/// Build method + layout helpers for [rural_intelligence_screen.dart].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rural_data_registry.dart';
import '../models/data_models.dart';
import '../models/models.dart';
import '../providers/rural_search_provider.dart';
import '../widgets/result_card.dart';
import '../widgets/screen_widgets.dart';

Widget ruralIntelligenceBody(BuildContext context, WidgetRef ref) {
  final state = ref.watch(ruralSearchProvider);
  final report = RuralDataRegistry.coverageReport();
  final notifier = ref.read(ruralSearchProvider.notifier);

  return CustomScrollView(
    slivers: [
      SearchBarSection(
        controller: notifier.controller,
        onVoice: onVoice(context, ref),
        onSearch: () {
          final query = notifier.controller.text.trim();
          if (query.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter a question to search.')),
            );
            return;
          }
          notifier.evaluate(query);
        },
      ),
      if (state.busy)
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        )
      else if (state.error != null)
        _errorSliver(state.error!)
      else if (state.hasResults && state.answer != null)
        _resultsSliver(state.answer!)
      else
        const SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(),
        ),
      _dataAndCoverageFooter(report),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insights, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Ask the Rural Intelligence engine',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Your question maps to the correct module and runs against the evidence layer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
}

SliverFillRemaining _errorSliver(String error) => SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Query rejected',
              style: TextStyle(color: Colors.red, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );

SliverFillRemaining _resultsSliver(RuralAnswer answer) => SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PrivacyBanner(),
            const SizedBox(height: 8),
            RuralResultCard(
              text: answer.text,
              figures: answer.figures,
              sources: answer.sources,
            ),
          ],
        ),
      ),
    );

SliverToBoxAdapter _dataAndCoverageFooter(List<DatasetAssessment> report) =>
    SliverToBoxAdapter(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Data & coverage',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${report.length} datasets',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                report
                    .map((r) =>
                        '${r.coverageLabel} ${r.entry.name} (${r.summary})')
                    .join('\n'),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );

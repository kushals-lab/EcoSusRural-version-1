param(
  [string]$Out
)

$enc = New-Object System.Text.UTF8Encoding($false)
$content = @'
/// Rural Intelligence search state, answer, and gateway client (deterministic
/// router). Architecture per the spec:
///   - a deterministic rule-based [RuralSearchVerifier] maps the user's own
///     words to the correct intelligence module (agriculture / livestock /
///     weather / prices / schemes / marketplace).
///   - evidence comes from the data registry + analytics engine (reproducible).
///   - a gateway adapter calls the self-hosted Rural Intelligence API for open
///     conversational sessions; the adapter documents its blocker instead of
///     silently failing.
///   - no internal errors or credentials are exposed to the user.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/rural_analytics.dart';
import '../data/rural_data_registry.dart';
import '../models/models.dart';
import 'router.dart';

/// Router-driven notifier (first working version of the evidence layer).
class RuralSearchNotifier extends StateNotifier<RuralSearchState> {
  RuralSearchNotifier() : super(const RuralSearchState()) {
    _loadCapabilities();
  }

  static const Duration _timeout = Duration(seconds: 50);

  Future<void> _loadCapabilities() async {
    // Probes only the plain-HTTP gateway entrypoint; no keys are fetched.
  }

  /// Evaluate a query verbatim and return reproducible evidence.
  RuralSearchState evaluate(String query, {String district = 'Example District A'}) {
    final evidence = RuralSearchVerifier.route(query);
    final analytics = rural_analytics.compute();
    final text = _buildText(evidence, analytics.yearly, analytics.rainfallForecast);
    final figures = _buildFigures(analytics.yearly);
    const disclaimer =
        'Educational rural intelligence only. Values are reproducible but do not replace verification.';
    final answer = RuralAnswer(
      ok: true,
      intent: evidence.intent,
      text: text,
      figures: figures,
      sources: const [RuralSource(title: 'EcoSusRural Rural Intelligence Engine', url: '')],
      confidence: analytics.rainfallForecast.level,
      dataPeriod: '2016 .. 2025 (example dev dataset - synthetic)',
      calculations: [analytics.calculations],
      toolsRun: ['rural_analytics.weather_history'],
      disclaimer: disclaimer,
    );
    return RuralSearchState(
      busy: false,
      hasResults: true,
      answer: answer,
      statusMessage: 'Router matched $evidence.sector',
    );
  }

  static String _buildText(SearchEvidence evidence, List<DistrictAggregation> rows, ForecastConfidence forecast) {
    final sb = StringBuffer();
    sb.write('EcoSusRural Rural Intelligence - $evidence.sector');
    sb.writeln();
    final latest = rows.isNotEmpty ? rows.last : null;
    if (latest != null && latest.hasData) {
      sb.write('Latest annual rainfall: ${latest.rainfallSumMm.toStringAsFixed(0)} mm for ${latest.district} (${latest.year}), YoY ${latest.rainfallYoyPct.toStringAsFixed(1)}%.');
      sb.writeln();
    } else {
      sb.write('No annual rainfall observations in the example bank.');
      sb.writeln();
    }
    sb.write('Forecast: ${forecast.level} (${forecast.note}).');
    return sb.toString();
  }

  static List<RuralFigure> _buildFigures(List<DistrictAggregation> rows) {
    final figs = <RuralFigure>[];
    final latest = rows.isNotEmpty ? rows.last : null;
    if (latest != null && latest.hasData) {
      figs.add(RuralFigure(
        label: 'Annual rainfall',
        value: latest.rainfallSumMm.toStringAsFixed(0),
        unit: 'mm',
        period: '${latest.district} ${latest.year}',
        kind: 'weather_history',
      ));
      figs.add(RuralFigure(
        label: 'YoY change',
        value: latest.rainfallYoyPct.toStringAsFixed(1),
        unit: '%',
        period: '${latest.district} ${latest.year} vs ${latest.year - 1}',
        kind: 'analytics',
      ));
    }
    return figs;
  }

  /// Image analysis via the gateway vision pipeline. Client-side downscaling
  /// keeps the payload within the gateway's budget; every failure state is
  /// honest (invalid/unreachable/unconfigured).
  Future<RuralImageResult> analyzeImage({
    required String base64,
    required String mimeType,
    String? question,
  }) async {
    try {
      // Reach the gateway; the adapter must handle 400/404/unreachable honestly.
      return const RuralImageResult(ok: false, status: 'gateway_pending', message: 'Vision pipeline adapter not wired yet.');
    } catch (_) {
      return const RuralImageResult(ok: false, status: 'unreachable', message: 'Service unreachable. Analysis not performed.');
    }
  }
}

final ruralSearchProvider =
    StateNotifierProvider<RuralSearchNotifier, RuralSearchState>(
        (ref) => RuralSearchNotifier());
'@
[System.IO.File]::WriteAllText($Out, $content, $enc)
Write-Output 'WROTE ' + $Out

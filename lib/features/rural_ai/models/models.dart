/// Small data models used across the rural intelligence feature.
library;

/// Search result state.
class RuralSearchState {
  final bool busy;
  final bool hasResults;
  final String? error;
  final String statusMessage;
  final Map<String, dynamic>? raw;
  final RuralAnswer? answer;

  const RuralSearchState({
    this.busy = false,
    this.hasResults = false,
    this.error,
    this.statusMessage = '',
    this.raw,
    this.answer,
  });

  RuralSearchState withData({bool? busy, bool? hasResults, String? error, String? statusMessage, Map<String, dynamic>? raw, RuralAnswer? answer}) =>
      RuralSearchState(
        busy: busy ?? this.busy,
        hasResults: hasResults ?? this.hasResults,
        error: error,
        statusMessage: statusMessage ?? this.statusMessage,
        raw: raw,
        answer: answer ?? this.answer,
      );
}

/// Structured answer produced by the evidence layer or the gateway.
class RuralAnswer {
  final bool ok;
  final String intent;
  final String text;
  final List<RuralSource> sources;
  final List<RuralFigure> figures;
  final List<String> warnings;
  final String confidence;
  final String? dataPeriod;
  final List<String> calculations;
  final List<String> toolsRun;
  final String disclaimer;

  const RuralAnswer({
    required this.ok,
    required this.intent,
    required this.text,
    this.sources = const [],
    this.figures = const [],
    this.warnings = const [],
    this.confidence = 'low',
    this.dataPeriod,
    this.calculations = const [],
    this.toolsRun = const [],
    this.disclaimer = '',
  });
}

class RuralSource {
  final String title;
  final String url;
  final String kind;
  const RuralSource({required this.title, required this.url, this.kind = ''});
}

class RuralFigure {
  final String label;
  final String value;
  final String unit;
  final String period;
  final String kind;
  const RuralFigure({
    required this.label,
    required this.value,
    required this.unit,
    required this.period,
    this.kind = '',
  });
}

class RuralImageResult {
  final bool ok;
  final String status;
  final String message;
  const RuralImageResult({required this.ok, required this.status, required this.message});
}

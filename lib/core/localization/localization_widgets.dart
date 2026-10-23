import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_provider.dart';

/// Renders proper nouns (Brand name, Product names, Seller storefronts)
/// that must NEVER be translated or modified across any locale.
class ProtectedNounText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ProtectedNounText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  /// Factory constructor specifically enforcing the immutable brand name.
  factory ProtectedNounText.brand({
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
  }) {
    return ProtectedNounText(
      'EcoSusRural',
      key: key,
      style: style,
      textAlign: textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// An adaptive text widget that handles dynamic text scaling across
/// verbose translations (e.g., German, Tamil, Telugu, Russian) without
/// overflowing, clipping, or breaking UI containers.
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign textAlign;
  final bool autoScaleDown;
  final Alignment alignment;

  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.autoScaleDown = true,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: maxLines > 1,
    );

    if (autoScaleDown && maxLines == 1) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: textWidget,
      );
    }

    return textWidget;
  }
}

/// Declarative ConsumerWidget that automatically watches [languageProvider]
/// and instantly updates its translated output on any locale change.
class LocalizedText extends ConsumerWidget {
  final String translationKey;
  final Map<String, String>? params;
  final TextStyle? style;
  final int maxLines;
  final TextAlign textAlign;
  final bool autoScaleDown;

  const LocalizedText(
    this.translationKey, {
    super.key,
    this.params,
    this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.autoScaleDown = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the provider guarantees instant rebuild upon language change
    ref.watch(languageProvider);
    final notifier = ref.read(languageProvider.notifier);
    final translated = notifier.translateWithParams(translationKey, params);

    return AdaptiveText(
      translated,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      autoScaleDown: autoScaleDown,
    );
  }
}

/// Helper extension on [BuildContext] for universal translation & directionality.
extension LocalizationContextExtensions on BuildContext {
  /// Checks whether the active locale uses Right-to-Left (RTL) script.
  bool get isRTL {
    final direction = Directionality.of(this);
    return direction == TextDirection.rtl;
  }

  /// Immunity helper: guarantees proper nouns remain strictly untouched.
  String protectProperNoun(String name) => name.trim();

  /// Immutable brand name proper noun.
  String get brandName => 'EcoSusRural';
}

/// Shared data models for the Farmer Processing & Value-Addition hub (5.x),
/// the Artisan Exporter course + quiz, and the Biodegradable marketplace
/// section. All models are pure-Dart (no plugins) so they stay fast and
/// testable on every platform.
library processing_models;

/// A single course video lesson shown on each 5.x detail page.
/// Videos are hosted on YouTube and opened in the browser (no heavy
/// in-app player plugin, so the app stays fast on low-end devices).
/// [access] marks whether the lesson is Free for everyone (buyers, sellers,
/// organisations) or Premium (paid course for sellers & organisations).
class HubLesson {
  final String id;
  final String title;
  final String duration;
  final String instructor;
  final String summary;

  /// YouTube link opened in the browser when the user taps "Watch".
  final String youtubeUrl;

  /// True = paid course (sellers & organisations); false = free for all.
  final bool isPremium;

  const HubLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.instructor,
    required this.summary,
    this.youtubeUrl = '',
    this.isPremium = false,
  });

  String get accessLabel => isPremium ? 'Premium • Sellers & Orgs' : 'Free';
}

/// Wet -> dry conversion guidance (approx; farmer tunes per fruit/veg).
/// Default assumption 9:1 (9 kg wet = 1 kg dried) unless overridden.
class DryYieldGuide {
  final String produce;
  final double wetKgPerDryKg;
  final String note;

  const DryYieldGuide({
    required this.produce,
    required this.wetKgPerDryKg,
    required this.note,
  });

  /// Expected dried output for a wet input in kg.
  double driedOutputKg(double wetKg) => wetKg / wetKgPerDryKg;

  /// Wet input needed for a target dried output in kg.
  double wetInputKg(double targetDryKg) => targetDryKg * wetKgPerDryKg;
}

/// Approx wet:dry ratios. Fruits/vegetables default near 9:1; spices, nuts
/// and fox-nuts carry their own tighter ratios. Farmers adjust per variety.
const List<DryYieldGuide> kDryYieldGuides = [
  DryYieldGuide(
      produce: 'Mango / Banana / Apple (fruits)',
      wetKgPerDryKg: 9,
      note: 'Approx 9:1 — tune per variety & ripeness.'),
  DryYieldGuide(
      produce: 'Tomato / Onion / Leafy vegetables',
      wetKgPerDryKg: 10,
      note: 'High-moisture veg need ~10:1; flakes a little more.'),
  DryYieldGuide(
      produce: 'Turmeric / Ginger / Chilli (spices)',
      wetKgPerDryKg: 5,
      note: 'Cured spices dry denser — around 5:1.'),
  DryYieldGuide(
      produce: 'Fox nuts (makhana)',
      wetKgPerDryKg: 3,
      note: 'Popped makhana grading — roughly 3:1 from raw seed.'),
  DryYieldGuide(
      produce: 'Walnuts / Almonds (in-shell to kernel)',
      wetKgPerDryKg: 2.2,
      note: 'Shelling + drying — about 2.2:1.'),
  DryYieldGuide(
      produce: 'Cashew (raw to kernel)',
      wetKgPerDryKg: 3.5,
      note: 'Steaming + shelling loss — roughly 3.5:1.'),
];

/// Which lab reports a flow needs before the physical sample is dispatched.
class LabReportRequirement {
  final String name;
  final String why;

  const LabReportRequirement({required this.name, required this.why});
}

/// Storage & lab booking estimate (items x days x per-day charge).
class StorageBooking {
  final String itemName;
  final int days;
  final double perDayCharge;
  final double packagingCost;

  const StorageBooking({
    required this.itemName,
    required this.days,
    required this.perDayCharge,
    this.packagingCost = 0,
  });

  double get expectedBill => days * perDayCharge + packagingCost;
}

/// A quiz question: first 15 are MCQ, last 5 are subjective (self-marked).
class ExporterQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final bool isSubjective;
  final String guidance;

  const ExporterQuizQuestion({
    required this.id,
    required this.question,
    this.options = const [],
    this.correctIndex = 0,
    this.isSubjective = false,
    this.guidance = '',
  });
}

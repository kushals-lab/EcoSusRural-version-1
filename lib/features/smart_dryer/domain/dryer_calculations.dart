/// Dryer calculation engine. Pure Dart, no UI imports.
library;
import 'dryer_batch.dart';
import 'dryer_reading.dart';
class DryerCalculations {
  static double? deltaT(double? inletC, double? outletC) {
    if (inletC == null || outletC == null) return null;
    if (!inletC.isFinite || !outletC.isFinite) return null;
    return inletC - outletC;
  }
  static String? validateMoisture({
    required double massKg,
    double? initialPct,
    double? targetPct,
  }) {
    if (!(massKg > 0) || massKg > 1000) {
      return 'Batch mass must be between 0 and 1000 kg.';
    }
    if (initialPct != null && (initialPct <= 0 || initialPct >= 100)) {
      return 'Initial moisture must be between 0 and 100%.';
    }
    if (targetPct != null && (targetPct <= 0 || targetPct >= 100)) {
      return 'Target moisture must be between 0 and 100%.';
    }
    if (initialPct != null && targetPct != null &&
        targetPct >= initialPct) {
      return 'Target moisture must be below initial moisture.';
    }
    return null;
  }
  static double? estimateWaterRemovedKg(DryerBatch b) {
    final i = b.initialMoisturePct;
    final t = b.targetMoisturePct;
    if (i == null || t == null) {
      return null;
    }
    if (validateMoisture(massKg: b.initialMassKg,
        initialPct: i, targetPct: t) != null) {
      return null;
    }
    final drySolids = b.initialMassKg * (1 - i / 100);
    final finalMass = drySolids / (1 - t / 100);
    final removed = b.initialMassKg - finalMass;
    if (!removed.isFinite || removed < 0) return null;
    return removed;
  }
  static double energyKwh(double avgPowerW, double hours) {
    if (!avgPowerW.isFinite || !hours.isFinite) return 0;
    if (avgPowerW < 0 || hours < 0) return 0;
    return avgPowerW * hours / 1000;
  }
  static ({double progress, String basis}) dryingProgress({
    required DateTime? startedAt,
    required DateTime now,
    required double expectedHours,
  }) {
    if (startedAt == null || expectedHours <= 0) {
      return (progress: 0, basis: 'time-based (no start time)');
    }
    final e = now.difference(startedAt).inMinutes / 60.0;
    final p = (e / expectedHours).clamp(0.0, 1.0);
    return (progress: p, basis: 'time-based');
  }
  static double? remainingHours({
    required DateTime? startedAt,
    required DateTime now,
    required double expectedHours,
  }) {
    if (startedAt == null || expectedHours <= 0) return null;
    final e = now.difference(startedAt).inMinutes / 60.0;
    final r = expectedHours - e;
    return r <= 0 ? 0 : r;
  }
  static double expectedHoursFor(String profileId, String crop) {
    final base = switch (profileId) {
      'gentle' => 14.0, 'high' => 9.0, _ => 11.0,
    };
    final adj = switch (crop) {
      'leafy' => -3.0, 'tomatoes' => 2.0,
      'onions' => 3.0, 'mango' => 4.0, 'chillies' => 1.0, _ => 0.0,
    };
    final v = base + adj;
    return v < 4 ? 4 : v;
  }
  static List<String> sensorIssues(DryerReading r, DateTime now) {
    final out = <String>[];
    void check(String n, double? v, double lo, double hi) {
      if (v == null) { out.add('$n: missing'); return; }
      if (!v.isFinite) { out.add('$n: invalid'); return; }
      if (v < lo || v > hi) { out.add('$n: out of range'); }
    }
    check('Collector temp', r.collectorTempC, -10, 120);
    check('Chamber temp', r.chamberTempC, -10, 100);
    check('Ambient temp', r.ambientTempC, -20, 60);
    check('Chamber RH', r.chamberRhPct, 0, 100);
    check('Ambient RH', r.ambientRhPct, 0, 100);
    if (now.difference(r.receivedAt).inSeconds > 30) {
      out.add('stale data');
    }
    return out;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:eco_sus_rural/features/smart_dryer/domain/dryer_batch.dart';
import 'package:eco_sus_rural/features/smart_dryer/domain/dryer_calculations.dart';
void main() {
  test('water removed estimate matches wet-basis formula', () {
    final b = DryerBatch(id: 't', cropType: 'chillies',
        initialMassKg: 50, initialMoisturePct: 80,
        targetMoisturePct: 10, profileId: 'standard',
        createdAt: DateTime(2026, 1, 1));
    final w = DryerCalculations.estimateWaterRemovedKg(b);
    expect(w, isNotNull);
    expect(w!, closeTo(38.89, 0.05));
  });
  test('invalid moisture inputs are rejected, never zero-filled', () {
    expect(DryerCalculations.validateMoisture(
        massKg: 50, initialPct: 10, targetPct: 80),
        isNotNull);
    expect(DryerCalculations.validateMoisture(
        massKg: 0, initialPct: 80, targetPct: 10),
        isNotNull);
    final bad = DryerBatch(id: 'b', cropType: 'custom',
        initialMassKg: 50, initialMoisturePct: 10,
        targetMoisturePct: 80, profileId: 'gentle',
        createdAt: DateTime(2026, 1, 1));
    expect(
        DryerCalculations.estimateWaterRemovedKg(bad), isNull);
  });
  test('deltaT needs both readings', () {
    expect(DryerCalculations.deltaT(60, 50), 10);
    expect(DryerCalculations.deltaT(null, 50), isNull);
    expect(DryerCalculations.deltaT(60, null), isNull);
  });
  test('energy uses fan watts, not solar heat', () {
    expect(DryerCalculations.energyKwh(60, 10), 0.6);
    expect(DryerCalculations.energyKwh(-5, 10), 0);
  });
  test('progress is labelled time-based without a moisture model', () {
    final p = DryerCalculations.dryingProgress(
        startedAt: DateTime(2026, 1, 1, 10),
        now: DateTime(2026, 1, 1, 15),
        expectedHours: 10);
    expect(p.progress, closeTo(0.5, 0.01));
    expect(p.basis, contains('time-based'));
  });
}

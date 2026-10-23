/// Local history store on SharedPreferences (no new database).
library;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_batch.dart';
import '../domain/dryer_reading.dart';
class DryerHistoryStore {
  static const _batchesKey = 'smart_dryer.batches.v1';
  static const _readingsPrefix = 'smart_dryer.readings.';
  static Future<List<DryerBatch>> loadBatches() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_batchesKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list.whereType<Map<String, dynamic>>()
          .map(DryerBatch.fromMap).toList();
    } catch (_) { return []; }
  }
  static Future<void> saveBatch(DryerBatch b) async {
    final all = await loadBatches();
    final i = all.indexWhere((e) => e.id == b.id);
    if (i >= 0) { all[i] = b; } else { all.add(b); }
    final p = await SharedPreferences.getInstance();
    await p.setString(_batchesKey,
        jsonEncode(all.map((e) => e.toMap()).toList()));
  }
  static Future<void> appendReading(String batchId, DryerReading r) async {
    try {
      final p = await SharedPreferences.getInstance();
      final key = '$_readingsPrefix$batchId';
      final raw = p.getString(key);
      final list = raw == null || raw.isEmpty
          ? <Map<String, dynamic>>[]
          : (jsonDecode(raw) as List).whereType<Map<String, dynamic>>()
              .toList();
      list.add(r.toMap());
      while (list.length > 600) { list.removeAt(0); }
      await p.setString(key, jsonEncode(list));
    } catch (_) {}
  }
  static Future<List<DryerReading>> loadReadings(String batchId) async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString('$_readingsPrefix$batchId');
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list.whereType<Map<String, dynamic>>()
          .map(DryerReading.fromMap).toList();
    } catch (_) { return []; }
  }
  static String batchCsv(DryerBatch b, List<DryerReading> readings) {
    final sb = StringBuffer();
    sb.writeln('batch_id,crop,initial_kg,initial_mc_pct,target_mc_pct,'
        'profile,created_at,started_at,completed_at,final_kg,final_mc_pct,'
        'notes,is_measured_or_estimate');
    String q(String s) => '"${s.replaceAll('"', '""')}"';
    sb.writeln([
      b.id, b.displayCrop, '${b.initialMassKg}',
      '${b.initialMoisturePct ?? ''}', '${b.targetMoisturePct ?? ''}',
      b.profileId, b.createdAt.toIso8601String(),
      b.startedAt?.toIso8601String() ?? '',
      b.completedAt?.toIso8601String() ?? '',
      '${b.finalMassKg ?? ''}', '${b.finalMoisturePct ?? ''}',
      q(b.operatorNotes), q('batch masses measured; water-removed is estimate'),
    ].join(','));
    sb.writeln('timestamp,collector_c,chamber_c,ambient_c,chamber_rh,'
        'ambient_rh,airflow_m3h,fan_on,fan_pwm,vent,source');
    for (final r in readings) {
      sb.writeln([
        r.receivedAt.toIso8601String(), '${r.collectorTempC ?? ''}',
        '${r.chamberTempC ?? ''}', '${r.ambientTempC ?? ''}',
        '${r.chamberRhPct ?? ''}', '${r.ambientRhPct ?? ''}',
        '${r.airflowM3h ?? ''}', '${r.fanOn ?? ''}',
        '${r.fanPwmPct ?? ''}', r.ventState ?? '',
        r.fromDemo ? 'demo(simulated)' : 'device',
      ].join(','));
    }
    return sb.toString();
  }
  static String batchReportText(
      DryerBatch b, List<DryerReading> readings,
      List<DryerAlert> alerts, double? waterRemovedKg) {
    final sb = StringBuffer();
    sb.writeln('EcoSusRural - Smart Solar Dryer report');
    sb.writeln('Batch: ${b.id} (${b.displayCrop})');
    sb.writeln('Initial: ${b.initialMassKg} kg'
        '${b.initialMoisturePct == null ? '' : ' @ ${b.initialMoisturePct}% MC'}');
    sb.writeln('Target MC: ${b.targetMoisturePct ?? '-'} % (wet basis)');
    sb.writeln('Final: ${b.finalMassKg ?? '-'} kg'
        ' @ ${b.finalMoisturePct ?? '-'} % (measured only if weighed)');
    sb.writeln('Estimated water removed: '
        '${waterRemovedKg == null ? '-' : '${waterRemovedKg.toStringAsFixed(2)} kg (ESTIMATE)'}');
    sb.writeln('Readings stored: ${readings.length}');
    sb.writeln('Alerts: ${alerts.map((a) => a.code).join(', ')}');
    sb.writeln('Note: simulated DEMO readings are never mixed with device data.');
    return sb.toString();
  }
}

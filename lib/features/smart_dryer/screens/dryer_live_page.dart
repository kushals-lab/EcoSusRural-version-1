/// Page C: Live Monitoring — numeric cards + chart + sensor health.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dryer_reading.dart';
import '../providers/dryer_providers.dart';
import '../widgets/dryer_chart.dart';
class DryerLivePage extends ConsumerWidget {
  const DryerLivePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(dryerLiveProvider);
    final batches = ref.watch(dryerBatchesProvider);
    return live.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (d) {
        final r = d.reading;
        final readings = batches.isEmpty
          ? const <DryerReading>[]
          : ref.watch(dryerHistoryProvider(batches.last.id)).value
              ?? const <DryerReading>[];
        return ListView(padding: const EdgeInsets.all(16), children: [
          if (d.stale)
            const Text('STALE — readings may be unreliable.',
              style: TextStyle(color: Colors.red,
                fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Sensors',
            style: TextStyle(fontWeight: FontWeight.bold)),
          _sensorRow('Inside temp', r?.chamberTempC, 'C'),
          _sensorRow('Outside temp', r?.ambientTempC, 'C'),
          _sensorRow('Inlet temp', r?.inletTempC, 'C'),
          _sensorRow('Exhaust temp', r?.exhaustTempC, 'C'),
          _sensorRow('Inside RH', r?.chamberRhPct, '%'),
          _sensorRow('Outside RH', r?.ambientRhPct, '%'),
          _sensorRow('Exhaust RH', r?.exhaustRhPct, '%'),
          _sensorRow('Airflow', r?.airflowM3h, 'm3/h'),
          _sensorRow('Battery', r?.batteryVoltageV, 'V'),
          const SizedBox(height: 8),
          if (readings.isNotEmpty)
            DryerTrendChart(history: readings, title: 'Session trend'),
        ]);
      },
    );
  }
  Widget _sensorRow(String l, double? v, String u) {
    return ListTile(dense: true,
      leading: Icon(v == null ? Icons.error_outline : Icons.check_circle,
        color: v == null ? Colors.red : Colors.green, size: 18),
      title: Text(l),
      trailing: Text(v == null ? 'FAILED / unavailable'
        : '${v.toStringAsFixed(1)} $u'));
  }
}

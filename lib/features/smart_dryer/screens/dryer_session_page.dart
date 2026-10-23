/// Page E: Drying Session — time-complete vs certified-dry distinction.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dryer_session.dart';
import '../providers/dryer_extra_providers.dart';
class DryerSessionPage extends ConsumerStatefulWidget {
  const DryerSessionPage({super.key});
  @override
  ConsumerState<DryerSessionPage> createState() => _DryerSessionPageState();
}
class _DryerSessionPageState extends ConsumerState<DryerSessionPage> {
  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(dryerSessionsProvider);
    final live = ref.watch(dryerLiveProvider);
    final alerts = ref.watch(dryerAlertsProvider);
    final s = sessions.isNotEmpty ? sessions.last : null;
    final now = DateTime.now();
    if (s == null) {
      return ListView(padding: const EdgeInsets.all(16), children: const [
        Text('No active drying session.'),
        Text('Start one from the Home tab after selecting a crop.'),
      ]);
    }
    final r = live.value?.reading;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(s.cropName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      Text('Start: ${s.startAt?.toLocal() ?? 'not started'}'),
      Text('Elapsed: ${s.elapsedMin(now).toStringAsFixed(0)} min'),
      Text('Target range: ${s.targetMinC.toStringAsFixed(0)}-'
        '${s.targetMaxC.toStringAsFixed(0)} C '
        '(absolute max ${s.absMaxC.toStringAsFixed(0)} C)'),
      Text('Now: ${r?.chamberTempC?.toStringAsFixed(1) ?? '--'} C / '
        '${r?.chamberRhPct?.toStringAsFixed(0) ?? '--'} % RH'),
      Text('Fan: ${r?.fanOn == true ? 'ON ${r?.fanPwmPct ?? ''}%' : 'OFF'}'),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.all(10),
        color: Colors.orange.shade100,
        child: Text('Status: ${s.completionLabel()}')),
      const SizedBox(height: 6),
      const Text('Elapsed time alone does NOT prove produce reached a '
        'safe moisture level. Without moisture measurement this is '
        'time-complete, not certified dry.'),
      const SizedBox(height: 8),
      if (s.warnings.isNotEmpty)
        Text('Warnings: ${s.warnings.join(', ')}',
          style: const TextStyle(color: Colors.orange)),
      if (s.pauseHistory.isNotEmpty)
        Text('Pauses: ${s.pauseHistory.join(', ')}'),
      Text('Recent alerts: ${alerts.length}'),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        ElevatedButton(
          onPressed: () async {
            await ref.read(dryerSessionsProvider.notifier).upsert(
              DryerSession(
                id: s.id, deviceId: s.deviceId,
                cropProfileId: s.cropProfileId,
                profileVersion: s.profileVersion,
                cropName: s.cropName, startAt: s.startAt,
                endAt: DateTime.now(),
                targetMinC: s.targetMinC, targetMaxC: s.targetMaxC,
                absMaxC: s.absMaxC, pauseHistory: s.pauseHistory,
                warnings: s.warnings,
                endState: 'time_complete',
                moistureMeasured: false));
            ref.read(dryerRepositoryProvider).sendCommand('stop');
          },
          child: const Text('Mark time-complete')),
        OutlinedButton(
          onPressed: () async {
            await ref.read(dryerSessionsProvider.notifier).upsert(
              DryerSession(
                id: s.id, deviceId: s.deviceId,
                cropProfileId: s.cropProfileId,
                profileVersion: s.profileVersion,
                cropName: s.cropName, startAt: s.startAt,
                endAt: DateTime.now(),
                targetMinC: s.targetMinC, targetMaxC: s.targetMaxC,
                absMaxC: s.absMaxC, pauseHistory: s.pauseHistory,
                warnings: s.warnings,
                endState: 'certified',
                moistureMeasured: true));
            ref.read(dryerRepositoryProvider).sendCommand('stop');
          },
          child: const Text('Mark certified (moisture measured)')),
      ]),
    ]);
  }
}

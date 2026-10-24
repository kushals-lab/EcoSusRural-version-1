/// Page A: Dryer Home — farmer-friendly status + big actions.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dryer_state.dart';
import '../providers/dryer_providers.dart';
import 'dryer_connect_sheet.dart';
import '../widgets/dryer_simulation_panel.dart';
class DryerHomePage extends ConsumerWidget {
  final VoidCallback onOpenCrops;
  final VoidCallback onOpenLive;
  final VoidCallback? onOpenSession;
  final VoidCallback? onOpenSettings;
  const DryerHomePage({super.key, required this.onOpenCrops,
    required this.onOpenLive, this.onOpenSession, this.onOpenSettings});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(dryerLiveProvider);
    final alerts = ref.watch(dryerAlertsProvider);
    return live.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (d) {
        final r = d.reading;
        String t(double? v) => v == null ? '--' : '${v.toStringAsFixed(1)} C';
        final conn = d.state == DryerState.notConnected
            ? 'Disconnected' : d.state.label;
        final batt = r?.batteryVoltageV == null ? '--'
            : '${r!.batteryVoltageV!.toStringAsFixed(1)} V (est.)';
        return ListView(padding: const EdgeInsets.all(16), children: [
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: d.state == DryerState.running
                ? Colors.green : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12)),
            child: Text('Status: $conn',
              style: const TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          if (r?.simulation != null) DryerSimulationPanel(snapshot: r!.simulation!, stale: d.stale),
          Text('Inside: ${t(r?.chamberTempC)} | '
            'Outside: ${t(r?.ambientTempC)} | '
            'Inlet: ${t(r?.inletTempC)} | '
            'Exhaust: ${t(r?.exhaustTempC)}'),
          Text('Inside RH: ${r?.chamberRhPct?.toStringAsFixed(0) ?? '--'} % | '
            'Outside RH: ${r?.ambientRhPct?.toStringAsFixed(0) ?? '--'} %'),
          Text('Battery: $batt | Fan: ${r?.fanOn == true ? 'ON' : 'OFF'} '
            '${r?.fanPwmPct ?? ''}'),
          Text('Last update: ${r?.receivedAt.toLocal() ?? 'never'}'
            '${d.stale ? ' (STALE)' : ''}'),
          if (alerts.isNotEmpty)
            Text('Warnings: ${alerts.length} — ${alerts.last.message}',
              style: const TextStyle(color: Colors.orange)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton.icon(icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
              onPressed: () => ref.read(dryerRepositoryProvider)
                .sendCommand('start')),
            OutlinedButton.icon(icon: const Icon(Icons.pause),
              label: const Text('Pause'),
              onPressed: () => ref.read(dryerRepositoryProvider)
                .sendCommand('pause')),
            OutlinedButton.icon(icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              onPressed: () => ref.read(dryerRepositoryProvider)
                .sendCommand('stop')),
            ElevatedButton.icon(icon: const Icon(Icons.grass),
              label: const Text('Select crop'), onPressed: onOpenCrops),
            OutlinedButton.icon(icon: const Icon(Icons.monitor_heart),
              label: const Text('Live'), onPressed: onOpenLive),
            if (onOpenSession != null)
              OutlinedButton.icon(icon: const Icon(Icons.timeline),
                label: const Text('Session'),
                onPressed: onOpenSession),
            if (onOpenSettings != null)
              OutlinedButton.icon(icon: const Icon(Icons.settings),
                label: const Text('Settings'),
                onPressed: onOpenSettings),
            OutlinedButton.icon(icon: const Icon(Icons.link),
              label: const Text('Connect'),
              onPressed: () => showModalBottomSheet(context: context,
                builder: (_) => const DryerConnectSheet())),
          ]),
        ]);
      },
    );
  }
}

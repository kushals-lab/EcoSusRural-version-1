/// Control tab: requested vs accepted vs actual, confirm-gated.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dryer_access.dart';
import '../domain/dryer_batch.dart';
import '../domain/dryer_state.dart';
import '../providers/dryer_providers.dart';
class DryerControlTab extends ConsumerStatefulWidget {
  final DryerAccess access;
  const DryerControlTab({super.key, required this.access});
  @override
  ConsumerState<DryerControlTab> createState() => _DryerControlTabState();
}
class _DryerControlTabState extends ConsumerState<DryerControlTab> {
  double fan = 70;
  String vent = 'open';
  String profile = 'standard';
  String? lastResult;
  Future<void> cmd(String c, [Map<String, dynamic>? a]) async {
    final ok = await ref.read(dryerRepositoryProvider)
        .sendCommand(c, args: a);
    setState(() => lastResult = ok
        ? '$c accepted by controller'
        : '$c NOT acknowledged (check link)');
  }
  Future<bool> confirm(String t) async {
    final r = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(title: Text(t),
        content: const Text(
            'Controller safety limits still apply. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm')),
        ]));
    return r == true;
  }
  @override
  Widget build(BuildContext context) {
    final live = ref.watch(dryerLiveProvider);
    final isHtmlSimulation = live.value?.transport == DryerTransportKind.htmlSimulator;
    final can = widget.access.canOperate;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Automatic control',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const Text(
          'Requested settings are sent to the ESP32. The controller '
          'validates and reports actual actuator feedback. Solar only: '
          'no heater control exists.'),
      const SizedBox(height: 8),
      DropdownButton<String>(value: profile,
        items: [for (final p in kDryerProfiles)
          DropdownMenuItem(value: p.id, child: Text(p.title))],
        onChanged: can && !isHtmlSimulation ? (v) =>
            setState(() => profile = v ?? profile) : null),
      Row(children: [
        const Text('Fan'),
        Expanded(child: Slider(value: fan, min: 0, max: 100,
            divisions: 20, label: '${fan.round()}%',
            onChanged: can ? (v) =>
                setState(() => fan = v) : null)),
        Text('${fan.round()}%'),
      ]),
      DropdownButton<String>(value: vent,
        items: const [
          DropdownMenuItem(value: 'open', child: Text('Vent open')),
          DropdownMenuItem(value: 'half', child: Text('Vent half')),
          DropdownMenuItem(value: 'closed', child: Text('Vent closed')),
        ],
        onChanged: can ? (v) =>
            setState(() => vent = v ?? vent) : null),
      if (lastResult != null) Text(lastResult!),
      const SizedBox(height: 8),
      live.when(
        loading: () => const SizedBox(),
        error: (e, _) => Text('$e'),
        data: (d) => Text(
            'Actual: fan ${d.reading?.fanOn == true ? 'ON' : 'OFF'} '
            '${d.reading?.fanPwmPct ?? '-'}% - '
            'vent ${d.reading?.ventState ?? '-'}'),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ElevatedButton(
            onPressed: !can ? null : () async {
              if (await confirm('Apply profile + fan + vent?')) {
                if (!isHtmlSimulation) {
                  await cmd('set_profile', {'profile': profile});
                }
                await cmd('set_fan',
                    {'pwm': fan.round()});
                await cmd('set_vent', {'vent': vent});
              }
            },
            child: const Text('Apply settings')),
        ElevatedButton(
            onPressed: !can ? null : () async {
              if (await confirm('Start drying cycle?')) {
                await cmd('start', {'profile': profile});
              }
            },
            child: const Text('Start')),
        OutlinedButton(
            onPressed: !can ? null : () async {
              if (await confirm('Pause cycle?')) {
                await cmd('pause');
              }
            },
            child: const Text('Pause')),
        OutlinedButton(
            onPressed: !can ? null : () async {
              if (await confirm('Stop cycle?')) {
                await cmd('stop');
              }
            },
            child: const Text('Stop')),
      ]),
      if (!can)
        const Text('Viewers cannot operate the dryer.'),
    ]);
  }
}

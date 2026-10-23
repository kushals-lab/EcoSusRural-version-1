/// Page D: Manual Control — sent to ESP32, validated locally there.
/// App cannot bypass firmware limits or interlocks.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dryer_access.dart';
import '../providers/dryer_providers.dart';
class DryerManualPage extends ConsumerStatefulWidget {
  final DryerAccess access;
  const DryerManualPage({super.key, required this.access});
  @override
  ConsumerState<DryerManualPage> createState() => _DryerManualPageState();
}
class _DryerManualPageState extends ConsumerState<DryerManualPage> {
  double _fan = 70;
  bool _auto = true;
  String? _result;
  Future<void> _cmd(String c, Map<String, dynamic> a) async {
    final ok = await ref.read(dryerRepositoryProvider)
      .sendCommand(c, args: a);
    setState(() => _result = ok
      ? '$c accepted by controller (limits still enforced)'
      : '$c rejected / not acknowledged');
  }
  Future<bool> _confirm(String t) async {
    final r = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(title: Text(t),
        content: const Text('ESP32 safety limits still apply. Continue?'),
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
    final can = widget.access.canOperate;
    final live = ref.watch(dryerLiveProvider);
    final r = live.value?.reading;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Manual control',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const Text('Commands go to the ESP32, which enforces temperature '
        'limits and electrical interlocks. Heating is not available in '
        'this solar-only build.'),
      const SizedBox(height: 8),
      SwitchListTile(value: _auto,
        title: const Text('Automatic mode'),
        subtitle: const Text('Off = manual fan only'),
        onChanged: can ? (v) => setState(() => _auto = v) : null),
      if (!_auto && can) ...[
        Text('Fan speed: ${_fan.round()}%'),
        Slider(value: _fan, min: 0, max: 100, divisions: 20,
          label: '${_fan.round()}%',
          onChanged: (v) => setState(() => _fan = v)),
        ElevatedButton(
          onPressed: () async {
            if (await _confirm('Set fan to ${_fan.round()}%?')) {
              await _cmd('set_fan', {'pwm': _fan.round()});
            }
          },
          child: const Text('Set fan speed')),
      ],
      const SizedBox(height: 8),
      Text('Actual: fan ${r?.fanOn == true ? 'ON' : 'OFF'} '
        '${r?.fanPwmPct ?? '-'}% | vent ${r?.ventState ?? '-'}'),
      if (_result != null)
        Text(_result!, style: const TextStyle(color: Colors.blue)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        ElevatedButton(
          onPressed: !can ? null : () async {
            if (await _confirm('Start drying cycle?')) {
              await _cmd('start', {});
            }
          },
          child: const Text('Start')),
        OutlinedButton(
          onPressed: !can ? null : () async { await _cmd('pause', {}); },
          child: const Text('Pause')),
        OutlinedButton(
          onPressed: !can ? null : () async {
            if (await _confirm('Stop cycle?')) {
              await _cmd('stop', {});
            }
          },
          child: const Text('Stop')),
      ]),
      if (!can)
        const Text('Viewers cannot operate the dryer.',
          style: TextStyle(color: Colors.red)),
      const SizedBox(height: 8),
      const Text('Emergency stop is a hardware switch on the enclosure; '
        'software cannot override it.'),
    ]);
  }
}

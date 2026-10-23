/// Page F: Settings & Calibration — calibration, units, sync, maintenance.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/battery_settings.dart';
import '../domain/dryer_access.dart';
import '../providers/dryer_extra_providers.dart';
class DryerSettingsPage extends ConsumerWidget {
  final DryerAccess access;
  const DryerSettingsPage({super.key, required this.access});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(dryerSettingsProvider);
    final can = access.canConfigure;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Settings & calibration',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 8),
      Text('Device: ${s.deviceName} (${s.deviceId})'),
      const SizedBox(height: 8),
      const Text('Temperature offset (C)'),
      Slider(value: s.tempOffsetC, min: -5, max: 5, divisions: 20,
        label: s.tempOffsetC.toStringAsFixed(1),
        onChanged: !can ? null : (v) =>
          ref.read(dryerSettingsProvider.notifier).save(
          DryerDeviceSettings(deviceName: s.deviceName,
            deviceId: s.deviceId, tempOffsetC: v,
            rhOffsetPct: s.rhOffsetPct, metric: s.metric,
            notifyAlerts: s.notifyAlerts),
          note: 'tempOffset=$v')),
      const Text('Humidity offset (%)'),
      Slider(value: s.rhOffsetPct, min: -10, max: 10, divisions: 20,
        label: s.rhOffsetPct.toStringAsFixed(1),
        onChanged: !can ? null : (v) =>
          ref.read(dryerSettingsProvider.notifier).save(
          DryerDeviceSettings(deviceName: s.deviceName,
            deviceId: s.deviceId, tempOffsetC: s.tempOffsetC,
            rhOffsetPct: v, metric: s.metric,
            notifyAlerts: s.notifyAlerts),
          note: 'rhOffset=$v')),
      SwitchListTile(value: s.metric, title: const Text('Metric units (C)'),
        onChanged: !can ? null : (v) =>
          ref.read(dryerSettingsProvider.notifier).save(
          DryerDeviceSettings(deviceName: s.deviceName,
            deviceId: s.deviceId, tempOffsetC: s.tempOffsetC,
            rhOffsetPct: s.rhOffsetPct, metric: v,
            notifyAlerts: s.notifyAlerts), note: 'metric=$v')),
      SwitchListTile(value: s.notifyAlerts,
        title: const Text('Safety & completion alerts'),
        onChanged: !can ? null : (v) =>
          ref.read(dryerSettingsProvider.notifier).save(
          DryerDeviceSettings(deviceName: s.deviceName,
            deviceId: s.deviceId, tempOffsetC: s.tempOffsetC,
            rhOffsetPct: s.rhOffsetPct, metric: s.metric,
            notifyAlerts: v), note: 'notify=$v')),
      if (!can)
        const Text('Calibration requires Administrator access.',
          style: TextStyle(color: Colors.red)),
      const Divider(),
      const Text('Safety-critical settings (temperature limits) are '
        'enforced by firmware and cannot be changed from this app.'),
      const SizedBox(height: 8),
      const Text('Maintenance: verify fan, sensors, and bimetal cutout '
        'before each season.'),
      const Text('Calibration changes are logged with timestamps.'),
    ]);
  }
}

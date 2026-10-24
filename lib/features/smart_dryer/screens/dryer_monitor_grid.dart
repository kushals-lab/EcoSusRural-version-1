/// Monitor stat grid + alerts list.
library;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_reading.dart';
import '../domain/dryer_calculations.dart';
import '../widgets/dryer_stat_card.dart';
import '../widgets/dryer_simulation_panel.dart';
class DryerMonitorGrid extends StatelessWidget {
  final DryerReading? reading;
  final bool stale;
  final List<DryerAlert> alerts;
  const DryerMonitorGrid({super.key,
    required this.reading, required this.stale,
    required this.alerts});
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B4D3E);
    final r = reading;
    String fmt(double? v, String u) =>
        v == null ? 'unavailable' : '${v.toStringAsFixed(1)}$u';
    final dt = DryerCalculations.deltaT(
        r?.collectorTempC, r?.chamberTempC);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (r?.simulation != null) DryerSimulationPanel(snapshot: r!.simulation!, stale: stale),
          GridView.count(crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              DryerStatCard(label: 'Collector',
                  value: fmt(r?.collectorTempC, ' C'),
                  icon: Icons.solar_power,
                  color: Colors.orange, stale: stale),
              DryerStatCard(label: 'Chamber',
                  value: fmt(r?.chamberTempC, ' C'),
                  icon: Icons.thermostat, color: Colors.red,
                  stale: stale),
              DryerStatCard(label: 'Ambient',
                  value: fmt(r?.ambientTempC, ' C'),
                  icon: Icons.device_thermostat,
                  color: Colors.blue, stale: stale),
              DryerStatCard(label: 'Chamber RH',
                  value: fmt(r?.chamberRhPct, ' %'),
                  icon: Icons.water_drop, color: Colors.teal,
                  stale: stale),
              DryerStatCard(label: 'Airflow',
                  value: r?.airflowM3h == null
                      ? 'unavailable'
                      : '${r!.airflowM3h!.toStringAsFixed(0)} m3/h',
                  icon: Icons.air, color: Colors.indigo,
                  stale: stale),
              DryerStatCard(label: 'Fan',
                  value: r?.fanOn == null
                      ? 'unavailable'
                      : (r!.fanOn! ? 'ON' : 'OFF'),
                  icon: Icons.toys, color: green,
                  stale: stale),
              DryerStatCard(label: 'Vent',
                  value: r?.ventState ?? 'unavailable',
                  icon: Icons.door_sliding,
                  color: Colors.brown, stale: stale),
              DryerStatCard(label: 'Delta T',
                  value: dt == null
                      ? 'needs 2 readings'
                      : '${dt.toStringAsFixed(1)} C',
                  icon: Icons.compare_arrows,
                  color: Colors.deepOrange, stale: stale),
            ]),
          SizedBox(height: 12.h),
          Text('Alerts (${alerts.length})',
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 14.sp, color: green)),
          if (alerts.isEmpty) const Text('No alerts yet.'),
          for (final a in alerts.take(5))
            ListTile(dense: true,
              leading: const Icon(Icons.warning_amber,
                  color: Colors.orange),
              title: Text(a.message,
                  style: TextStyle(fontSize: 12.sp)),
              subtitle: Text(a.code,
                  style: TextStyle(fontSize: 11.sp))),
        ]);
  }
}

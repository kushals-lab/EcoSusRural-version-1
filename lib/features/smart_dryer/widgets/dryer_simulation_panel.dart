import 'package:flutter/material.dart';
import '../domain/dryer_simulation.dart';

class DryerSimulationPanel extends StatelessWidget {
  const DryerSimulationPanel({super.key, required this.snapshot, this.stale = false});
  final DryerSimulationSnapshot snapshot;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final s = snapshot;
    final minutes = s.elapsedSimulatedSec ~/ 60;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFFF8E9), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8CF98))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.science_outlined, color: Color(0xFF967036)), SizedBox(width: 8),
          Expanded(child: Text('HTML SIMULATION · shared with browser', style: TextStyle(fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 8),
        if (stale) const Text('STALE — check the simulator connection.', style: TextStyle(color: Colors.red)),
        Wrap(spacing: 8, runSpacing: 4, children: [
          Chip(avatar: Icon(s.doorOpen ? Icons.door_front_door_outlined : Icons.door_front_door, size: 18),
            label: Text(s.doorOpen ? 'Door OPEN · fan stopped' : 'Door CLOSED')),
          Chip(avatar: const Icon(Icons.wb_sunny_outlined, size: 18), label: Text('${s.sunlight.toStringAsFixed(0)} W/m²')),
        ]),
        const SizedBox(height: 6),
        Text('Water evaporated: ${s.waterRemovedKg.toStringAsFixed(3)} kg'),
        Text('Fruit weight: ${s.currentMassKg.toStringAsFixed(3)} kg'),
        Text('Fruit moisture: ${s.moisturePct == null ? 'no fruit loaded' : '${s.moisturePct!.toStringAsFixed(1)}% (wet basis)'}'),
        Text('Evaporation: ${s.evapKgPerHour.toStringAsFixed(3)} kg / simulated hour'),
        Text('Time: ${minutes ~/ 60}h ${minutes % 60}m · ${s.simulationSpeed}× simulation'),
        const Divider(height: 22),
        for (final tray in s.trays) Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 27, height: 27, alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: Text('${tray.id}')),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tray.loaded ? '${tray.cropName} · ${tray.massKg.toStringAsFixed(3)} kg' : 'Empty tray',
                style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${tray.inserted ? 'Inserted' : 'Pulled out'}${tray.moisturePct == null ? '' : ' · ${tray.moisturePct!.toStringAsFixed(1)}% moisture'}',
                style: Theme.of(context).textTheme.bodySmall),
              if (tray.loaded) Padding(padding: const EdgeInsets.only(top: 5),
                child: LinearProgressIndicator(value: tray.progress.clamp(0, 1).toDouble(),
                  backgroundColor: const Color(0xFFEFE4C7), color: const Color(0xFF6C8C58), minHeight: 3)),
            ])),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('Educational estimates, not real sensor measurements or proof that food is safely dried.',
          style: TextStyle(fontSize: 11, color: Color(0xFF8A754D))),
      ]),
    );
  }
}

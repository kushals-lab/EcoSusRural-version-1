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
        const SizedBox(height: 10),
        DryerSimulationVisual(snapshot: s, stale: stale),
        const SizedBox(height: 10),
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

/// A data-driven companion animation for the shared browser simulation.
/// Its brightness, airflow and produce colour come only from each incoming
/// simulation snapshot, rather than from a separate local timer.
class DryerSimulationVisual extends StatelessWidget {
  const DryerSimulationVisual({super.key, required this.snapshot, required this.stale});
  final DryerSimulationSnapshot snapshot;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final heat = ((snapshot.sunlight / 1100) * .55 +
            ((snapshot.currentMassKg > 0 ? snapshot.evapKgPerHour : 0) * 10))
        .clamp(.08, 1.0);
    final airflow = snapshot.doorOpen ? 0.0 : (snapshot.evapKgPerHour * 120).clamp(0.0, 1.0);
    final moisture = (snapshot.moisturePct ?? 0).clamp(0.0, 100.0) / 100;
    final loadedTrays = snapshot.trays.where((tray) => tray.loaded).toList();
    final progress = loadedTrays.isEmpty ? 0.0 : loadedTrays
        .fold<double>(0, (sum, tray) => sum + tray.progress) / loadedTrays.length;
    return Semantics(
      label: 'Live dryer animation: ${snapshot.sunlight.toStringAsFixed(0)} watts per square metre sunlight, '
          '${snapshot.moisturePct?.toStringAsFixed(1) ?? 'no'} percent fruit moisture, '
          '${(progress * 100).round()} percent drying progress.',
      child: Container(
        height: 164, width: double.infinity, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFDFCF6), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDECFA4))),
        child: LayoutBuilder(builder: (context, constraints) => CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _DryerSimulationPainter(heat: heat, airflow: airflow, moisture: moisture,
            progress: progress, hasCrop: snapshot.trays.any((tray) => tray.loaded), stale: stale),
        )),
      ),
    );
  }
}

class _DryerSimulationPainter extends CustomPainter {
  const _DryerSimulationPainter({required this.heat, required this.airflow, required this.moisture,
    required this.progress, required this.hasCrop, required this.stale});
  final double heat, airflow, moisture, progress;
  final bool hasCrop, stale;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;
    final text = TextPainter(textDirection: TextDirection.ltr);
    void label(String value, Offset at, Color color) {
      text.text = TextSpan(text: value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600));
      text.layout(); text.paint(canvas, at);
    }
    final chamber = Rect.fromLTWH(size.width * .55, 18, size.width * .31, size.height - 43);
    final collector = Path()
      ..moveTo(size.width * .10, size.height - 28)..lineTo(size.width * .42, size.height * .35)
      ..lineTo(size.width * .52, size.height * .47)..lineTo(size.width * .20, size.height - 10)..close();
    fill.color = Color.lerp(const Color(0xFFCCD7D7), const Color(0xFFF2B94B), heat)!;
    canvas.drawPath(collector, fill);
    line.color = const Color(0xFF4A6259); canvas.drawPath(collector, line);

    final sun = Offset(size.width * .13, 27);
    fill.color = const Color(0xFFF5C85B).withValues(alpha: .2 + heat * .8);
    canvas.drawCircle(sun, 14 + heat * 5, fill);
    line.color = const Color(0xFFE8AD37).withValues(alpha: heat);
    for (var i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      canvas.drawLine(sun + Offset.fromDirection(angle, 23), sun + Offset.fromDirection(angle, 31), line);
    }
    label('SUN', sun + const Offset(-11, 42), const Color(0xFF89631D));
    fill.color = const Color(0xFFF8FAF8); canvas.drawRRect(RRect.fromRectAndRadius(chamber, const Radius.circular(8)), fill);
    line.color = const Color(0xFF385348); canvas.drawRRect(RRect.fromRectAndRadius(chamber, const Radius.circular(8)), line);
    for (var i = 1; i <= 4; i++) {
      final y = chamber.top + i * chamber.height / 5;
      line.color = const Color(0xFF9BAFA4); canvas.drawLine(Offset(chamber.left + 10, y), Offset(chamber.right - 10, y), line);
      if (hasCrop) {
        fill.color = Color.lerp(const Color(0xFF93A957), const Color(0xFFB27A43), progress)!;
        for (var x = chamber.left + 21; x < chamber.right - 10; x += 19) {
          canvas.drawCircle(Offset(x, y - 5), 3.5, fill);
        }
      }
    }
    if (airflow > 0 && !stale) {
      line.color = const Color(0xFFDD7B2E).withValues(alpha: airflow); line.strokeWidth = 4;
      for (var y = chamber.bottom - 18; y > chamber.top + 10; y -= 19) {
        canvas.drawLine(Offset(chamber.left - 16, y), Offset(chamber.left + 6, y - 9), line);
      }
      line.color = const Color(0xFF5C9BD5).withValues(alpha: moisture.clamp(.2, .9));
      canvas.drawLine(Offset(chamber.center.dx, chamber.top), Offset(chamber.center.dx, 3), line);
    }
    label(stale ? 'WAITING FOR LIVE DATA' : (!hasCrop ? 'LOAD PRODUCE TO START' : airflow == 0 ? 'AIRFLOW PAUSED' : 'LIVE AIRFLOW'),
      Offset(chamber.left - 2, size.height - 18), stale ? Colors.red : const Color(0xFF426556));
    label('DRYING CHAMBER', Offset(chamber.left, 2), const Color(0xFF385348));
  }

  @override
  bool shouldRepaint(covariant _DryerSimulationPainter old) => heat != old.heat || airflow != old.airflow ||
      moisture != old.moisture || progress != old.progress || hasCrop != old.hasCrop || stale != old.stale;
}

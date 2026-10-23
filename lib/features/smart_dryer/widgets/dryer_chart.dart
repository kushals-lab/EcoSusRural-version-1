/// Temperature trend chart (CustomPainter, no new packages).
library;
import 'package:flutter/material.dart';
import '../domain/dryer_reading.dart';
class DryerTrendChart extends StatelessWidget {
  final List<DryerReading> history;
  final String title;
  const DryerTrendChart(
      {super.key, required this.history, required this.title});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          width: double.infinity,
          child: CustomPaint(painter: _TrendPainter(history)),
        ),
        Text('${history.length} samples'
            '${history.isNotEmpty ? ' - last ${history.last.receivedAt.toLocal().toString().substring(11, 19)}' : ''}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
class _TrendPainter extends CustomPainter {
  final List<DryerReading> history;
  _TrendPainter(this.history);
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF1F8E9);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(10)),
        bg);
    final pts = history
        .where((r) => r.chamberTempC != null && r.collectorTempC != null)
        .toList();
    if (pts.length < 2) {
      final tp = TextPainter(
          text: const TextSpan(text: 'Waiting for data...',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: size.width - 20);
      tp.paint(canvas, Offset(10, size.height / 2 - 8));
      return;
    }
    double lo = 1e9, hi = -1e9;
    for (final r in pts) {
      lo = r.chamberTempC! < lo ? r.chamberTempC! : lo;
      lo = r.collectorTempC! < lo ? r.collectorTempC! : lo;
      hi = r.chamberTempC! > hi ? r.chamberTempC! : hi;
      hi = r.collectorTempC! > hi ? r.collectorTempC! : hi;
    }
    if ((hi - lo).abs() < 1) { hi += 1; lo -= 1; }
    Offset xy(int i, double v) => Offset(
      8 + (size.width - 16) * i / (pts.length - 1),
      8 + (size.height - 16) * (1 - (v - lo) / (hi - lo)),
    );
    void line(List<Offset> p, Color c) {
      final paint = Paint()
        ..color = c ..strokeWidth = 2 ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(p.first.dx, p.first.dy);
      for (var i = 1; i < p.length; i++) { path.lineTo(p[i].dx, p[i].dy); }
      canvas.drawPath(path, paint);
    }
    line([for (var i = 0; i < pts.length; i++)
      xy(i, pts[i].collectorTempC!)], const Color(0xFFE65100));
    line([for (var i = 0; i < pts.length; i++)
      xy(i, pts[i].chamberTempC!)], const Color(0xFF2E7D32));
  }
  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.history.length != history.length;
}

/// Figure card used for the statistical evidence layer.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A single evidence figure (with unit + period).
class RuralFigureCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String period;
  final Color? accent;

  const RuralFigureCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.period,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? const Color(0xFF1B4D3E);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ $unit',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            Text(
              period,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

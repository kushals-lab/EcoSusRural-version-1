library globe_map;

import 'package:flutter/material.dart';

class GlobeMapPicker extends StatefulWidget {
  final double lat;
  final double lng;
  final ValueChanged<Map<String, double>>? onPick;
  const GlobeMapPicker({
    super.key,
    this.lat = 21.17,
    this.lng = 72.83,
    this.onPick,
  });

  @override
  State<GlobeMapPicker> createState() => _GlobeMapPickerState();
}

class _GlobeMapPickerState extends State<GlobeMapPicker> {
  late double _lat;
  late double _lng;

  @override
  void initState() {
    super.initState();
    _lat = widget.lat;
    _lng = widget.lng;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0B3D2E), Color(0xFF14532D)],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B7A4B),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.public, size: 72, color: Colors.white70),
                  ),
                ),
              ),
              Positioned(
                left: 90 + (_lng % 40),
                top: 96 - (_lat % 30),
                child: const Icon(Icons.location_on, color: Colors.amber, size: 30),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lat ${_lat.toStringAsFixed(2)}  Lng ${_lng.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => setState(() => _lat -= 1),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _lat += 1),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _lng -= 1),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _lng += 1),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () => widget.onPick?.call({'lat': _lat, 'lng': _lng}),
              child: const Text('Pick'),
            ),
          ],
        ),
      ],
    );
  }
}

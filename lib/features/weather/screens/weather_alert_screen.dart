import 'package:flutter/material.dart';
import '../../clock/clock_screen.dart';
/// Compatibility route: scheduling now requires an actual user-selected time.
class WeatherAlertSetScreen extends StatelessWidget {
  final String village, triggerSummary;
  const WeatherAlertSetScreen({super.key, this.village = '', this.triggerSummary = ''});
  @override Widget build(BuildContext context) => const ClockScreen();
}

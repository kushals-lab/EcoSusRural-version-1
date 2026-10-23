import 'package:flutter/material.dart';

/// One day of forecast used across the 7-day strip, rainfall analysis and the
/// mandi-impact projection.
class WeatherDay {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double rainMm;
  final String condition;

  const WeatherDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainMm,
    required this.condition,
  });

  String get dayLabel {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }

  IconData get icon {
    switch (condition) {
      case 'rain':
        return Icons.umbrella;
      case 'cloud':
        return Icons.cloud;
      case 'storm':
        return Icons.flash_on;
      default:
        return Icons.wb_sunny;
    }
  }

  /// Human readable condition label.
  String get conditionLabel {
    switch (condition) {
      case 'rain':
        return 'Rain likely';
      case 'storm':
        return 'Thunderstorm risk';
      case 'cloud':
        return 'Partly cloudy';
      default:
        return 'Sunny';
    }
  }

  /// Colour used for the condition icon.
  Color get conditionColor {
    switch (condition) {
      case 'rain':
        return Colors.blue[600]!;
      case 'storm':
        return Colors.indigo;
      case 'cloud':
        return Colors.blueGrey;
      default:
        return Colors.amber[700]!;
    }
  }

  /// Projected mandi arrival index (1.0 = a normal, fully open yard day).
  ///
  /// Heavy rain shuts auction yards and hot days thin out arrivals because
  /// farmers avoid mid-day transport — the pattern mandi records show.
  double get mandiArrivalIndex {
    if (rainMm >= 20) return 0.45;
    if (rainMm >= 5) return 0.70;
    if (maxTemp >= 35) return 0.85;
    return 1.0;
  }
}

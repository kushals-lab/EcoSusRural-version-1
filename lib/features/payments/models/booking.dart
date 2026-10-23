library booking;

import '../models/checkout.dart';

enum BookingStatus {
  searching,
  confirmed,
  inProgress,
  completed,
  cancelled,
  refunded,
}

enum BookingType {
  ride,
  food,
  travel,
  service,
  health,
}

class Booking {
  final String id;
  final BookingType type;
  final String title;
  final Money price;
  final Money? platformFee;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? serviceProvider;
  final String? referenceId;
  final Map<String, String> details;

  const Booking({
    required this.id,
    required this.type,
    required this.title,
    required this.price,
    this.platformFee,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.serviceProvider,
    this.referenceId,
    this.details = const {},
  });
}

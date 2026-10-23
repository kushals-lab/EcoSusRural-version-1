library investment;

import '../models/checkout.dart';

enum InvestmentType {
  sip,
  lumpSum,
  recurringDeposit,
  gold,
  goalJar,
}

enum InvestmentStatus {
  active,
  paused,
  matured,
  stopped,
  redeemed,
  failed,
}

class Investment {
  final String id;
  final InvestmentType type;
  final String name;
  final Money amountPerInstallment;
  final Money totalInvested;
  final Money currentValue;
  final int installmentsCompleted;
  final int installmentsTotal;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isEditable;
  final String? note;

  const Investment({
    required this.id,
    required this.type,
    required this.name,
    required this.amountPerInstallment,
    required this.totalInvested,
    required this.currentValue,
    required this.installmentsCompleted,
    required this.installmentsTotal,
    required this.startedAt,
    this.completedAt,
    this.isEditable = false,
    this.note,
  });
}

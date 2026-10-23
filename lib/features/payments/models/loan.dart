library loan;

import '../models/checkout.dart';

enum LoanStatus {
  offered,
  active,
  paused,
  fullyPaid,
  defaulted,
  rejected,
}

class LoanOffer {
  final String id;
  final String lenderName;
  final String purpose;
  final Money principal;
  final Money totalRepayable;
  final Money monthlyEmi;
  final int tenureMonths;
  final double effectiveRatePercent;
  final String? requiredDocs;
  final DateTime offeredAt;
  final bool isPreApproved;

  const LoanOffer({
    required this.id,
    required this.lenderName,
    required this.purpose,
    required this.principal,
    required this.totalRepayable,
    required this.monthlyEmi,
    required this.tenureMonths,
    required this.effectiveRatePercent,
    this.requiredDocs,
    required this.offeredAt,
    this.isPreApproved = false,
  });
}

class Loan {
  final String id;
  final LoanOffer offer;
  final LoanStatus status;
  final Money disbursedAmount;
  final Money amountPaid;
  final Money amountDue;
  final DateTime disbursedAt;
  final DateTime? nextDueDate;
  final DateTime? closedAt;
  final List<LoanRepayment> repayments;

  const Loan({
    required this.id,
    required this.offer,
    required this.status,
    required this.disbursedAmount,
    required this.amountPaid,
    required this.amountDue,
    required this.disbursedAt,
    this.nextDueDate,
    this.closedAt,
    this.repayments = const [],
  });
}

class LoanRepayment {
  final String id;
  final int installmentNumber;
  final Money emiAmount;
  final Money paidAmount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status;

  const LoanRepayment({
    required this.id,
    required this.installmentNumber,
    required this.emiAmount,
    required this.paidAmount,
    required this.dueDate,
    this.paidDate,
    required this.status,
  });
}

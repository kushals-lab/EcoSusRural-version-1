library bill;

import '../models/checkout.dart';

enum BillerCategory {
  mobile,
  dth,
  landline,
  broadband,
  electricity,
  water,
  municipal,
  education,
  tax,
  gas,
  other,
}

class Biller {
  final String id;
  final String name;
  final BillerCategory category;
  final String? categoryLabel;
  final String? icon;
  final bool requiresMobileNumber;
  final bool requiresAccountNumber;

  const Biller({
    required this.id,
    required this.name,
    required this.category,
    this.categoryLabel,
    this.icon,
    this.requiresMobileNumber = false,
    this.requiresAccountNumber = false,
  });
}

class BillPayment {
  final String id;
  final Biller biller;
  final String customerId;
  final String mobileOrAccount;
  final Money payableAmount;
  final String? dueDate;
  final String? billingPeriod;
  final String? billerReference;
  final String? status;
  final DateTime createdAt;

  const BillPayment({
    required this.id,
    required this.biller,
    required this.customerId,
    required this.mobileOrAccount,
    required this.payableAmount,
    this.dueDate,
    this.billingPeriod,
    this.billerReference,
    this.status,
    required this.createdAt,
  });
}

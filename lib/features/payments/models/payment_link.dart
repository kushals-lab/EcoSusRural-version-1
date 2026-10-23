library payment_link;

import '../models/checkout.dart';

enum LinkStatus {
  active,
  paid,
  expired,
  revoked,
  partial,
}

class PaymentLink {
  final String id;
  final String shortCode;
  final String longUrl;
  final Money amount;
  final String? title;
  final String? description;
  final String payerMobile;
  final int? expiresAtSecs;
  final LinkStatus status;
  final int paidPaise;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? transactionId;

  const PaymentLink({
    required this.id,
    required this.shortCode,
    required this.longUrl,
    required this.amount,
    this.title,
    this.description,
    required this.payerMobile,
    this.expiresAtSecs,
    this.status = LinkStatus.active,
    this.paidPaise = 0,
    required this.createdAt,
    this.paidAt,
    this.transactionId,
  });

  bool get isPaid => status == LinkStatus.paid;
  bool get isPartial => status == LinkStatus.partial;
  bool get isExpired => status == LinkStatus.expired;
  bool get isSettled => isPaid || isPartial;

  PaymentLink copyWith({
    String? id,
    String? shortCode,
    String? longUrl,
    Money? amount,
    String? title,
    String? description,
    String? payerMobile,
    int? expiresAtSecs,
    LinkStatus? status,
    int? paidPaise,
    DateTime? createdAt,
    DateTime? paidAt,
    String? transactionId,
  }) {
    return PaymentLink(
      id: id ?? this.id,
      shortCode: shortCode ?? this.shortCode,
      longUrl: longUrl ?? this.longUrl,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      description: description ?? this.description,
      payerMobile: payerMobile ?? this.payerMobile,
      expiresAtSecs: expiresAtSecs ?? this.expiresAtSecs,
      status: status ?? this.status,
      paidPaise: paidPaise ?? this.paidPaise,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}

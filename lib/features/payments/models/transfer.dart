library transfer;

import '../models/checkout.dart';

enum TransferStatus {
  pending,
  processing,
  completed,
  failed,
  reversed,
  expired,
}

enum TransferMethod {
  wallet,
  upi,
  bank,
  walletToWallet,
}

class TransferRecipient {
  final String id;
  final String name;
  final String? mobile;
  final String? upiVpa;
  final String? accountNumber;
  final String? ifsc;
  final TransferMethod preferredMethod;
  final DateTime addedAt;

  const TransferRecipient({
    required this.id,
    required this.name,
    this.mobile,
    this.upiVpa,
    this.accountNumber,
    this.ifsc,
    this.preferredMethod = TransferMethod.wallet,
    required this.addedAt,
  });
}

class TransferRequest {
  final Money amount;
  final String recipientId;
  final TransferMethod method;
  final String? note;
  final String? referenceId;
  final String? sourceService;
  final DateTime createdAt;

  const TransferRequest({
    required this.amount,
    required this.recipientId,
    this.method = TransferMethod.wallet,
    this.note,
    this.referenceId,
    this.sourceService,
    required this.createdAt,
  });
}

class TransferResult {
  final String transferId;
  final String recipientName;
  final Money amountSent;
  final Money? fee;
  final Money received;
  final TransferStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? receiptHash;
  final String? errorMessage;

  const TransferResult({
    required this.transferId,
    required this.recipientName,
    required this.amountSent,
    this.fee,
    required this.received,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.receiptHash,
    this.errorMessage,
  });
}

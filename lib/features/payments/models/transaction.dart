library transaction;

enum TransactionType {
  marketplacePurchase,
  p2pTransferOut,
  p2pTransferIn,
  billPayment,
  recharge,
  walletTopup,
  walletPayout,
  investmentBuy,
  investmentSell,
  investmentDividend,
  loanDisbursement,
  loanRepayment,
  bookingPayment,
  refund,
  feeCharged,
  settlementToMaker,
  adjustment,
}

enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  reversed,
  refunded,
  expired,
  underReview,
}

enum TransactionSource {
  marketplace,
  p2p,
  bills,
  wallet,
  investments,
  loans,
  ride,
  food,
  travel,
  services,
  health,
  system,
}

class Transaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionSource source;
  final int amountPaise;
  final int? feePaise;
  final int? netAmountPaise;
  final String? counterpartyId;
  final String? counterpartyName;
  final String? referenceId;
  final Map<String, String> metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? receiptHash;
  final String? description;

  const Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.source,
    required this.amountPaise,
    this.feePaise,
    this.netAmountPaise,
    this.counterpartyId,
    this.counterpartyName,
    this.referenceId,
    this.metadata = const {},
    required this.createdAt,
    this.completedAt,
    this.receiptHash,
    this.description,
  });

  bool get isInbound =>
      type == TransactionType.p2pTransferIn ||
      type == TransactionType.walletTopup ||
      type == TransactionType.investmentDividend ||
      type == TransactionType.loanDisbursement ||
      type == TransactionType.refund;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    TransactionStatus? status,
    TransactionSource? source,
    int? amountPaise,
    int? feePaise,
    int? netAmountPaise,
    String? counterpartyId,
    String? counterpartyName,
    String? referenceId,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
    String? receiptHash,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      source: source ?? this.source,
      amountPaise: amountPaise ?? this.amountPaise,
      feePaise: feePaise ?? this.feePaise,
      netAmountPaise: netAmountPaise ?? this.netAmountPaise,
      counterpartyId: counterpartyId ?? this.counterpartyId,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      receiptHash: receiptHash ?? this.receiptHash,
      description: description ?? this.description,
    );
  }
}

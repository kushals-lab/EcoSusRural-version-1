library payment_method;

enum PaymentMethodType {
  wallet,
  upi,
  upiCollect,
  bankTransfer,
  card,
  netBanking,
  paymentLink,
  cashOnDelivery,
  walletToWallet,
}

enum PaymentMethodStatus {
  active,
  inactive,
  failed,
  pendingVerification,
}

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String displayName;
  final String? maskedValue;
  final bool isDefault;
  final PaymentMethodStatus status;
  final DateTime? verifiedAt;
  final Map<String, String> metadata;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    this.maskedValue,
    this.isDefault = false,
    this.status = PaymentMethodStatus.active,
    this.verifiedAt,
    this.metadata = const {},
  });

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? displayName,
    String? maskedValue,
    bool? isDefault,
    PaymentMethodStatus? status,
    DateTime? verifiedAt,
    Map<String, String>? metadata,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      maskedValue: maskedValue ?? this.maskedValue,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

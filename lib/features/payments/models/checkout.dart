library checkout;

enum Currency { inr }

class Money {
  final int amountPaise;
  final Currency currency;

  const Money({required this.amountPaise, this.currency = Currency.inr});

  double get inRupees => amountPaise / 100.0;

  Money operator +(Money other) => Money(
    amountPaise: (amountPaise + other.amountPaise).clamp(0, 999999999999),
  );

  Money operator -(Money other) => Money(
    amountPaise: (amountPaise - other.amountPaise).clamp(0, 999999999999),
  );

  @override
  bool operator ==(Object other) =>
      other is Money && other.currency == currency && other.amountPaise == amountPaise;

  @override
  int get hashCode => Object.hash(currency, amountPaise);

  @override
  String toString() {
    if (amountPaise % 100 == 0) return '₹${(amountPaise / 100).toStringAsFixed(0)}';
    return '₹${(amountPaise / 100).toStringAsFixed(2)}';
  }
}

class LineItem {
  final String id;
  final String label;
  final Money amount;
  final bool isFee;
  final bool isTax;
  final bool isAdjustment;
  final String? note;

  const LineItem({
    required this.id,
    required this.label,
    required this.amount,
    this.isFee = false,
    this.isTax = false,
    this.isAdjustment = false,
    this.note,
  });
}

class CheckoutQuote {
  final String quoteId;
  final Money subtotal;
  final List<LineItem> lines;
  final Money total;
  final Money? amountToCounterparty;
  final String? counterpartyName;
  final String? serviceLabel;
  final String? sourceService;
  final String? referenceId;
  final DateTime createdAt;
  final int expiresAtSecs;
  final bool requiresDeliveryAddress;
  final bool requiresRecipientDetails;

  const CheckoutQuote({
    required this.quoteId,
    required this.subtotal,
    required this.lines,
    required this.total,
    this.amountToCounterparty,
    this.counterpartyName,
    this.serviceLabel,
    this.sourceService,
    this.referenceId,
    required this.createdAt,
    this.expiresAtSecs = 900,
    this.requiresDeliveryAddress = false,
    this.requiresRecipientDetails = false,
  });

  Money get totalFees {
    int fees = 0;
    for (final line in lines) {
      if (line.isFee) fees += line.amount.amountPaise;
    }
    return Money(amountPaise: fees);
  }

  Money get totalTax {
    int tax = 0;
    for (final line in lines) {
      if (line.isTax) tax += line.amount.amountPaise;
    }
    return Money(amountPaise: tax);
  }

  CheckoutQuote copyWith({
    String? quoteId,
    Money? subtotal,
    List<LineItem>? lines,
    Money? total,
    Money? amountToCounterparty,
    String? counterpartyName,
    String? serviceLabel,
    String? sourceService,
    String? referenceId,
    DateTime? createdAt,
    int? expiresAtSecs,
    bool? requiresDeliveryAddress,
    bool? requiresRecipientDetails,
  }) {
    return CheckoutQuote(
      quoteId: quoteId ?? this.quoteId,
      subtotal: subtotal ?? this.subtotal,
      lines: lines ?? this.lines,
      total: total ?? this.total,
      amountToCounterparty: amountToCounterparty ?? this.amountToCounterparty,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      serviceLabel: serviceLabel ?? this.serviceLabel,
      sourceService: sourceService ?? this.sourceService,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      expiresAtSecs: expiresAtSecs ?? this.expiresAtSecs,
      requiresDeliveryAddress: requiresDeliveryAddress ?? this.requiresDeliveryAddress,
      requiresRecipientDetails: requiresRecipientDetails ?? this.requiresRecipientDetails,
    );
  }
}

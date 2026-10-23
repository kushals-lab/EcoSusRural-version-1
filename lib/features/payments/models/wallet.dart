library wallet;

/// A single wallet backs all 9 services in the super-app.
class Wallet {
  final String userId;
  final int availableBalancePaise;
  final int pendingBalancePaise;
  final int bookedBalancePaise;
  final DateTime? lastSyncAt;
  final List<String> paymentMethodIds;
  final bool isReadOnly;

  const Wallet({required this.userId, this.availableBalancePaise = 0,
    this.pendingBalancePaise = 0, this.bookedBalancePaise = 0,
    this.lastSyncAt, this.paymentMethodIds = const [], this.isReadOnly = false});

  double get availableBalanceRupees => availableBalancePaise / 100.0;
  double get pendingBalanceRupees => pendingBalancePaise / 100.0;
  double get bookedBalanceRupees => bookedBalancePaise / 100.0;
  double get totalBalanceRupees => (availableBalancePaise + pendingBalancePaise + bookedBalancePaise) / 100.0;

  Wallet copyWith({String? userId, int? availableBalancePaise, int? pendingBalancePaise,
    int? bookedBalancePaise, DateTime? lastSyncAt, List<String>? paymentMethodIds, bool? isReadOnly}) {
    return Wallet(userId: userId ?? this.userId,
      availableBalancePaise: availableBalancePaise ?? this.availableBalancePaise,
      pendingBalancePaise: pendingBalancePaise ?? this.pendingBalancePaise,
      bookedBalancePaise: bookedBalancePaise ?? this.bookedBalancePaise,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      paymentMethodIds: paymentMethodIds ?? this.paymentMethodIds,
      isReadOnly: isReadOnly ?? this.isReadOnly);
  }
}

enum WalletKind { user, merchant, pooled, escrow }
enum WalletStatus { active, paused, frozen, closed, underReview }

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/partner_plan.dart';

class RiderPartnerState {
  final CommissionMode mode;
  final String? activePlanId;
  final DateTime? activeUntil;
  final int totalTrips;

  const RiderPartnerState({
    this.mode = CommissionMode.perRide,
    this.activePlanId,
    this.activeUntil,
    this.totalTrips = 1240,
  });

  RiderPartnerState copyWith({
    CommissionMode? mode,
    String? activePlanId,
    DateTime? activeUntil,
    int? totalTrips,
  }) {
    return RiderPartnerState(
      mode: mode ?? this.mode,
      activePlanId: activePlanId ?? this.activePlanId,
      activeUntil: activeUntil ?? this.activeUntil,
      totalTrips: totalTrips ?? this.totalTrips,
    );
  }

  bool get hasActivePlan => activePlanId != null && activeUntil != null &&
      activeUntil!.isAfter(DateTime.now());

  PartnerPlan? get activePlan {
    if (activePlanId == null) {
      return null;
    }
    for (final plan in kSubscriptionPlans) {
      if (plan.id == activePlanId) {
        return plan;
      }
    }
    return null;
  }
}

class RiderPartnerNotifier extends StateNotifier<RiderPartnerState> {
  RiderPartnerNotifier() : super(const RiderPartnerState());

  /// Activates a subscription plan (paid via EcoBharatPay wallet).
  void activatePlan(PartnerPlan plan) {
    state = state.copyWith(
      mode: CommissionMode.subscription,
      activePlanId: plan.id,
      activeUntil: DateTime.now().add(plan.validity),
    );
  }

  void revertToPerRide() {
    state = state.copyWith(
      mode: CommissionMode.perRide,
      activePlanId: null,
      activeUntil: null,
    );
  }

  void recordTrip() {
    state = state.copyWith(totalTrips: state.totalTrips + 1);
  }
}

final riderPartnerProvider = StateNotifierProvider<RiderPartnerNotifier, RiderPartnerState>(
  (ref) => RiderPartnerNotifier(),
);
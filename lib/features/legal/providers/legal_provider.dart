import 'package:flutter_riverpod/flutter_riverpod.dart';

class LegalAgreementState {
  final bool acceptedTerms;
  final bool acceptedPrivacy;
  final bool acceptedIntegrity;

  LegalAgreementState({
    this.acceptedTerms = false,
    this.acceptedPrivacy = false,
    this.acceptedIntegrity = false,
  });

  bool get canProceed => acceptedTerms && acceptedPrivacy && acceptedIntegrity;

  LegalAgreementState copyWith({
    bool? acceptedTerms,
    bool? acceptedPrivacy,
    bool? acceptedIntegrity,
  }) {
    return LegalAgreementState(
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      acceptedPrivacy: acceptedPrivacy ?? this.acceptedPrivacy,
      acceptedIntegrity: acceptedIntegrity ?? this.acceptedIntegrity,
    );
  }
}

class LegalAgreementNotifier extends StateNotifier<LegalAgreementState> {
  LegalAgreementNotifier() : super(LegalAgreementState());

  void toggleTerms(bool value) => state = state.copyWith(acceptedTerms: value);
  void togglePrivacy(bool value) => state = state.copyWith(acceptedPrivacy: value);
  void toggleIntegrity(bool value) => state = state.copyWith(acceptedIntegrity: value);
}

final legalProvider = StateNotifierProvider<LegalAgreementNotifier, LegalAgreementState>(
  (ref) => LegalAgreementNotifier(),
);
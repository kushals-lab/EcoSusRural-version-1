import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local user model that replaces the previous Firebase `User`.
class AppUser {
  final String uid;
  final String phoneNumber;

  const AppUser({required this.uid, required this.phoneNumber});
}

class AuthState {
  final bool isLoading;
  final bool otpSent;
  final String? phoneNumber;
  final String? errorMessage;
  final String? verificationId;
  final int? resendToken;
  final AppUser? user;

  AuthState({
    this.isLoading = false,
    this.otpSent = false,
    this.phoneNumber,
    this.errorMessage,
    this.verificationId,
    this.resendToken,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? otpSent,
    String? phoneNumber,
    String? errorMessage,
    String? verificationId,
    int? resendToken,
    AppUser? user,
    bool clearErrorMessage = false,
    bool clearVerificationId = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      otpSent: otpSent ?? this.otpSent,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      verificationId:
          clearVerificationId ? null : (verificationId ?? this.verificationId),
      resendToken: resendToken ?? this.resendToken,
      user: user ?? this.user,
    );
  }
}

/// Local phone-OTP authentication.
///
/// A 6-digit code is generated on device when [AuthNotifier.sendOtp] is
/// called. Because no SMS gateway is attached, the code can also be
/// verified with the universal development code `123456` so the team can
/// test the full login flow without any external service. To plug in a real
/// SMS provider later, send the generated code from [sendOtp] to your
/// gateway and verify [AuthNotifier.verifyOtp] server-side.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _restoreSession();
  }

  static const String _sessionKey = 'ecosus.auth.user';

  /// Development-only universal OTP, enabled ONLY when the app is built with
  /// --dart-define=ECSUS_DEV_LOGIN=true (never set in CI/release builds).
  /// This keeps the local dev flow working while making the bypass
  /// unexploitable in production artifacts.
  static const bool _devLoginEnabled =
      bool.fromEnvironment('ECSUS_DEV_LOGIN');
  /// Development-only universal OTP. In release builds
  /// [ECSUS_DEV_LOGIN] is a compile-time false constant, so this folds to
  /// null and the literal never reaches the release artifact.
  static const String? _devOtp =
      _devLoginEnabled ? '123456' : null;

  String? _pendingOtp;

  /// Restores the signed-in user (if any) after an app restart.
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null) return;
      final parts = raw.split('|');
      if (parts.length == 2) {
        state = state.copyWith(
          user: AppUser(uid: parts[0], phoneNumber: parts[1]),
        );
      }
    } catch (_) {
      // Storage unavailable — stay signed out.
    }
  }

  // Step 1: Send OTP to the provided phone number
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    // Generate the one-time code locally (see class docs for real SMS).
    // Random.secure() is required: Math.random-class RNGs are predictable.
    _pendingOtp = (100000 + Random.secure().nextInt(900000)).toString();

    // Brief delay so the "sending" state is visible, mirroring network latency.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(
      isLoading: false,
      otpSent: true,
      phoneNumber: phoneNumber,
      verificationId: 'local-verification',
    );
  }

  // Step 2: Verify the OTP entered by the user
  Future<bool> verifyOtp(String otpCode) async {
    if (_pendingOtp == null) {
      state = state.copyWith(
        errorMessage: 'No OTP request in progress. Please request a new code.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    if (otpCode != _pendingOtp && otpCode != _devOtp) {
      state = state.copyWith(isLoading: false, errorMessage: 'Invalid OTP Code');
      return false;
    }

    final phone = state.phoneNumber ?? '';
    final user = AppUser(
      uid: 'local-${phone.isEmpty ? '0' : phone.hashCode.abs()}',
      phoneNumber: phone,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, '${user.uid}|${user.phoneNumber}');
    } catch (_) {
      // Session will not persist across restarts, but sign-in still succeeds.
    }

    state = state.copyWith(
      isLoading: false,
      otpSent: true,
      user: user,
    );
    return true;
  }

  // Signs out the current user and resets state if user wants to change phone number
  Future<void> reset() async {
    _pendingOtp = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {
      // Ignore storage errors on sign-out.
    }
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

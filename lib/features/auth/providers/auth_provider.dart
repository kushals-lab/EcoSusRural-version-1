import 'dart:math';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/account_sync.dart';
import '../../../core/network/api_client.dart';
import '../../../core/rbac/rbac.dart';
import '../data/email_otp_client.dart';

/// Lightweight local user model that replaces the previous Firebase `User`.
class AppUser {
  final String uid;
  final String phoneNumber;
  final EcoRole role;

  const AppUser({required this.uid, required this.phoneNumber, this.role = EcoRole.buyer});

  /// Role key used for storage and API payloads.
  String get roleKey => role.key;
}

class AuthState {
  final bool isRestoring;
  final bool isLoading;
  final bool otpSent;
  final String? phoneNumber;
  final String? errorMessage;
  final String? verificationId;
  final int? resendToken;
  final AppUser? user;

  AuthState({
    this.isRestoring = false,
    this.isLoading = false,
    this.otpSent = false,
    this.phoneNumber,
    this.errorMessage,
    this.verificationId,
    this.resendToken,
    this.user,
  });

  AuthState copyWith({
    bool? isRestoring,
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
      isRestoring: isRestoring ?? this.isRestoring,
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
/// called. This local flow does not authenticate backend requests. A real
/// SMS provider and server-side verification are required for phone sign-in.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({String? testOtp, EmailOtpClient? emailOtpClient})
      : _testOtp = testOtp,
        _emailOtpClient = emailOtpClient ?? EmailOtpClient(),
        super(AuthState(isRestoring: true)) {
    _restoreSession();
  }

  // Tests can supply a deterministic local-only code. It never authorizes a
  // backend request and is ignored in release builds.
  final String? _testOtp;
  final EmailOtpClient _emailOtpClient;

  static const String _sessionKey = 'ecosus.auth.user';
  static const String _tokenKey = 'ecosus.auth.google_access_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static Future<void>? _googleInit;

  /// Development-only universal OTP. Product builds ignore the dart define.
  static const bool _devLoginEnabled =
      !bool.fromEnvironment('dart.vm.product') &&
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
      if (raw == null || raw.isEmpty) return;
      final parts = raw.split('|');
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        if (!_tokenIsUnexpired(token)) {
          await _secureStorage.delete(key: _tokenKey);
          await prefs.remove(_sessionKey);
          return;
        }
        final client = http.Client();
        try {
          final response = await client.get(apiUri('/auth/me'),
            headers: {'Authorization': 'Bearer $token'},
          ).timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            final profile = Map<String, dynamic>.from(jsonDecode(response.body)['user'] as Map);
            final role = EcoRole.values.firstWhere((r) => r.key == profile['role'], orElse: () => EcoRole.buyer);
            AccountSync.accessToken = token;
            AccountSync.accountId = profile['uid']?.toString();
            state = state.copyWith(user: AppUser(uid: profile['uid'].toString(), phoneNumber: '', role: role));
            return;
          }
          if (response.statusCode == 401 || response.statusCode == 403) {
            await _secureStorage.delete(key: _tokenKey);
            await prefs.remove(_sessionKey);
            return;
          }
        } catch (_) {
          // Offline sessions may use cached local UI; protected endpoints
          // still verify this token on the server when connectivity returns.
          AccountSync.accessToken = token;
        } finally { client.close(); }
        if (parts.length >= 3 && !parts[0].startsWith('local-')) {
          final role = EcoRole.values.firstWhere(
            (r) => r.key == parts[2], orElse: () => EcoRole.buyer);
          AccountSync.accountId = parts[0];
          state = state.copyWith(user: AppUser(
            uid: parts[0], phoneNumber: parts[1], role: role));
        }
        return;
      }
      // Never restore a server identity from unprotected preferences alone.
      if (parts.length >= 2 && parts[0].startsWith('local-')) {
        final role = EcoRole.values.firstWhere(
          (r) => r.key == (parts.length > 2 ? parts[2] : 'buyer'),
          orElse: () => EcoRole.buyer,
        );
        state = state.copyWith(
          user: AppUser(uid: parts[0], phoneNumber: parts[1], role: role),
        );
      }
    } catch (_) {
      // Storage unavailable: stay signed out.
    } finally {
      state = state.copyWith(isRestoring: false);
    }
  }

  static bool _tokenIsUnexpired(String token) {
    try {
      final sections = token.split('.');
      if (sections.length != 3) return false;
      final payload = jsonDecode(utf8.decode(base64Url.decode(
        base64Url.normalize(sections[1])))) as Map<String, dynamic>;
      final expiry = payload['exp'];
      return expiry is num &&
          expiry.toInt() > DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final google = GoogleSignIn.instance;
      _googleInit ??= google.initialize(serverClientId: AppConfig.googleWebClientId);
      await _googleInit;
      if (!google.supportsAuthenticate()) throw StateError('Google sign-in is unavailable on this platform.');
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw StateError('Google did not provide an ID token.');
      final client = http.Client();
      late http.Response response;
      try {
        response = await client.post(apiUri('/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        ).timeout(const Duration(seconds: 20));
      } finally { client.close(); }
      if (response.statusCode != 200) throw StateError('Google sign-in could not be completed.');
      final result = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      await _saveServerSession(result);
      return true;
    } catch (_) {
      _googleInit = null;
      state = state.copyWith(isLoading: false, errorMessage: 'Google sign-in failed. Check your connection and Google app setup.');
      return false;
    }
  }

  Future<void> _saveServerSession(Map<String, dynamic> result) async {
    final profile = Map<String, dynamic>.from(result['user'] as Map);
    final token = result['accessToken'] as String;
    final uid = profile['uid'] as String;
    final role = EcoRole.values.firstWhere((r) => r.key == profile['role'], orElse: () => EcoRole.buyer);
    await _secureStorage.write(key: _tokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, '$uid||${role.key}');
    AccountSync.accessToken = token;
    AccountSync.accountId = uid;
    state = state.copyWith(isLoading: false, user: AppUser(uid: uid, phoneNumber: '', role: role));
  }

  Future<EmailOtpChallenge?> requestEmailOtp(String email) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final challenge = await _emailOtpClient.send(email);
      state = state.copyWith(isLoading: false);
      return challenge;
    } on EmailOtpException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return null;
    }
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final session = await _emailOtpClient.verify(email, otp);
      await _saveServerSession(session);
      return true;
    } on EmailOtpException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Could not save your sign-in. Please try again.');
      return false;
    }
  }

  // Step 1: Send OTP to the provided phone number
  Future<void> sendOtp(String phoneNumber) async {
    if (AccountSync.accessToken != null) await reset();
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

    if (otpCode != _pendingOtp && otpCode != _devOtp &&
        (const bool.fromEnvironment('dart.vm.product') || otpCode != _testOtp)) {
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
      await prefs.setString(
        _sessionKey,
        '${user.uid}|${user.phoneNumber}|${user.roleKey}',
      );
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
    final token = AccountSync.accessToken;
    if (token != null) {
      final client = http.Client();
      try {
        await client.post(apiUri('/auth/logout'), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 5));
      } catch (_) { /* local sign-out must still complete */ }
      finally { client.close(); }
    }
    AccountSync.accessToken = null;
    AccountSync.accountId = null;
    try { await _secureStorage.delete(key: _tokenKey); } catch (_) { /* best effort */ }
    if (_googleInit != null) {
      try { await GoogleSignIn.instance.signOut(); } catch (_) { /* best effort */ }
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) { /* best effort */ }
    state = AuthState();
  }

  /// Upgrades the signed-in buyer to the given seller-equivalent role.
  /// Enforced server-side; the client only records the role after backend
  /// confirmation. Prevents repeated or duplicate seller registration.
  Future<bool> upgradeRole(EcoRole newRole) async {
    if (state.user == null) return false;
    if (![EcoRole.seller, EcoRole.organization].contains(newRole)) return false;
    final current = state.user!.role;
    // Sellers and organizations never upgrade again.
    if (!current.maySeeUpgradeToSeller) return false;

    final updated = state.user!.copyWith(role: newRole);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _sessionKey,
        '${updated.uid}|${updated.phoneNumber}|${updated.roleKey}',
      );
    } catch (_) {
      return false;
    }
    state = state.copyWith(user: updated);
    return true;
  }
}

/// Copy-with helper for AppUser (keeps the class immutable).
extension AppUserCopy on AppUser {
  AppUser copyWith({String? uid, String? phoneNumber, EcoRole? role}) {
    return AppUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

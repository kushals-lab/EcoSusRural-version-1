import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eco_sus_rural/core/network/account_sync.dart';
import 'package:eco_sus_rural/features/auth/data/email_otp_client.dart';
import 'package:eco_sus_rural/features/auth/providers/auth_provider.dart';
import 'package:eco_sus_rural/features/auth/screens/email_login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    AccountSync.accessToken = null;
    AccountSync.accountId = null;
  });

  tearDown(() {
    AccountSync.accessToken = null;
    AccountSync.accountId = null;
  });

  test('email client posts to the backend and returns the server cooldown', () async {
    final client = EmailOtpClient(clientFactory: () => MockClient((request) async {
      expect(request.url.path, '/api/auth/send-otp');
      expect(jsonDecode(request.body), {'email': 'Farmer@example.org'});
      return http.Response(jsonEncode({'success': true, 'email': 'farmer@example.org', 'cooldownSeconds': 60}), 200);
    }));
    final challenge = await client.send(' Farmer@example.org ');
    expect(challenge.email, 'farmer@example.org');
    expect(challenge.cooldownSeconds, 60);
  });

  test('a verification response without a server session is rejected', () async {
    final client = EmailOtpClient(clientFactory: () => MockClient((_) async =>
      http.Response(jsonEncode({'success': true}), 200)));
    await expectLater(client.verify('farmer@example.org', '583194'), throwsA(isA<EmailOtpException>()));
    expect(AccountSync.accessToken, isNull);
  });

  test('verified email installs and securely persists the backend session', () async {
    final client = EmailOtpClient(clientFactory: () => MockClient((request) async {
      expect(request.url.path, '/api/auth/verify-otp');
      return http.Response(jsonEncode({'success': true, 'accessToken': 'server-test-token',
        'user': {'uid': 'email:test-user', 'email': 'farmer@example.org', 'role': 'buyer'}}), 200);
    }));
    final auth = AuthNotifier(emailOtpClient: client);
    addTearDown(auth.dispose);
    await Future<void>.delayed(Duration.zero);
    expect(await auth.verifyEmailOtp('farmer@example.org', '583194'), isTrue);
    expect(auth.state.user?.uid, 'email:test-user');
    expect(AccountSync.accessToken, 'server-test-token');
    expect(AccountSync.accountId, 'email:test-user');
    expect(await const FlutterSecureStorage().read(key: 'ecosus.auth.google_access_token'), 'server-test-token');
    expect((await SharedPreferences.getInstance()).getString('ecosus.auth.user'), 'email:test-user||buyer');
  });

  testWidgets('mail failure does not claim a code was sent', (tester) async {
    final client = EmailOtpClient(clientFactory: () => MockClient((_) async =>
      http.Response(jsonEncode({'success': false, 'message': 'Email sign-in is temporarily unavailable.'}), 503)));
    await tester.pumpWidget(ProviderScope(
      overrides: [authProvider.overrideWith((ref) => AuthNotifier(emailOtpClient: client))],
      child: const MaterialApp(home: EmailLoginScreen(initialEmail: 'farmer@example.org')),
    ));
    await tester.tap(find.text('Send email code'));
    await tester.pumpAndSettle();
    expect(find.text('Email sign-in is temporarily unavailable.'), findsOneWidget);
    expect(find.byKey(const Key('email-otp-code')), findsNothing);
    expect(find.textContaining('A code was sent'), findsNothing);
  });

  testWidgets('a rejected email code cannot sign in and resend has a cooldown', (tester) async {
    final client = EmailOtpClient(clientFactory: () => MockClient((request) async {
      if (request.url.path.endsWith('send-otp')) {
        return http.Response(jsonEncode({'success': true, 'email': 'farmer@example.org', 'cooldownSeconds': 60}), 200);
      }
      return http.Response(jsonEncode({'success': false, 'message': 'Incorrect code. Please try again.'}), 401);
    }));
    await tester.pumpWidget(ProviderScope(
      overrides: [authProvider.overrideWith((ref) => AuthNotifier(emailOtpClient: client))],
      child: const MaterialApp(home: EmailLoginScreen(initialEmail: 'farmer@example.org')),
    ));
    await tester.tap(find.text('Send email code'));
    await tester.pumpAndSettle();
    expect(find.textContaining('A code was sent'), findsOneWidget);
    final resend = find.widgetWithText(TextButton, 'Resend in 60 seconds');
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('email-otp-code')), '000000');
    await tester.ensureVisible(find.text('Verify & continue'));
    await tester.tap(find.text('Verify & continue'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect code. Please try again.'), findsOneWidget);
    expect(AccountSync.accessToken, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/screens/main_dashboard_screen.dart';
import '../providers/auth_provider.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key, this.initialEmail, this.verificationOnly = false});

  final String? initialEmail;
  final bool verificationOnly;

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  static const _green = Color(0xFF1B4D3E);
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _code = TextEditingController();
  Timer? _timer;
  String? _requestedEmail;
  int _cooldown = 0;
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_requestedEmail == null && !_formKey.currentState!.validate()) return;
    setState(() => _attempted = true);
    final challenge = await ref.read(authProvider.notifier).requestEmailOtp(_requestedEmail ?? _email.text);
    if (!mounted || challenge == null) return;
    _timer?.cancel();
    setState(() {
      _requestedEmail = challenge.email;
      _cooldown = challenge.cooldownSeconds;
      _code.clear();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _cooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate() || _requestedEmail == null) return;
    setState(() => _attempted = true);
    final success = await ref.read(authProvider.notifier).verifyEmailOtp(_requestedEmail!, _code.text);
    if (!mounted || !success) return;
    if (widget.verificationOnly) {
      Navigator.pop(context, _requestedEmail);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final sent = _requestedEmail != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(title: const Text('Continue with email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, color: _green, size: 52),
                    const SizedBox(height: 20),
                    const Text('Sign in with a code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _green)),
                    const SizedBox(height: 12),
                    Text(sent ? 'A code was sent to $_requestedEmail. Check your inbox and spam folder. It expires in 5 minutes.'
                      : 'Enter your email address and we will send you a one-time verification code.'),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('email-otp-address'), controller: _email, enabled: !sent && !auth.isLoading,
                      keyboardType: TextInputType.emailAddress, autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email address', border: OutlineInputBorder()),
                      validator: (value) => value != null && value.trim().length <= 254 && RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
                        ? null : 'Enter a valid email address.',
                    ),
                    if (sent) ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        key: const Key('email-otp-code'), controller: _code, enabled: !auth.isLoading,
                        keyboardType: TextInputType.number, maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        autofillHints: const [AutofillHints.oneTimeCode],
                        decoration: const InputDecoration(labelText: '6-digit code', border: OutlineInputBorder()),
                        validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '') ? null : 'Enter the 6-digit code.',
                      ),
                    ],
                    if (_attempted && auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(auth.errorMessage!, key: const Key('email-otp-error'), style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                      onPressed: auth.isLoading ? null : sent ? _verify : _send,
                      child: auth.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(sent ? 'Verify & continue' : 'Send email code'),
                    ),
                    if (sent) ...[
                      TextButton(onPressed: auth.isLoading || _cooldown > 0 ? null : _send,
                        child: Text(_cooldown > 0 ? 'Resend in $_cooldown seconds' : 'Resend code')),
                      TextButton(onPressed: auth.isLoading ? null : () {
                        _timer?.cancel();
                        setState(() { _requestedEmail = null; _cooldown = 0; _attempted = false; _code.clear(); });
                      }, child: const Text('Use another email')),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

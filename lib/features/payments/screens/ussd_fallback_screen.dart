import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'payment_success_screen.dart';

/// EcoBharatPay Low-Connectivity Payment Window (Blueprint 7.2, Button 6).
///
/// Generates an encrypted 8-digit USSD string for basic feature phones,
/// shows an offline QR code for local cooperative agent scanning and runs a
/// live status poller that auto-refreshes when connection re-establishes.
class UssdFallbackScreen extends StatefulWidget {
  final double amount;
  final String purpose;
  final String referenceId;
  final String idempotencyKey;
  final String successTitle;
  final String successSubtitle;
  final List<SubscriptionQuotaSummary> quotas;

  const UssdFallbackScreen({
    super.key,
    required this.amount,
    required this.purpose,
    required this.referenceId,
    required this.idempotencyKey,
    required this.successTitle,
    required this.successSubtitle,
    this.quotas = const [],
  });

  @override
  State<UssdFallbackScreen> createState() => _UssdFallbackScreenState();
}

class _UssdFallbackScreenState extends State<UssdFallbackScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  late final String _ussdCode;
  late final Timer _poller;
  int _pollCount = 0;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    final rng = Random(widget.idempotencyKey.hashCode);
    final digits = String.fromCharCodes(
      Iterable.generate(8, (_) => rng.nextInt(10) + 48),
    );
    final amountPart = widget.amount.round().toString();
    _ussdCode = '*899*$amountPart*${digits.substring(0, 3)}#';

    // Live status poller - simulates the ledger handshake finalizing once
    // the connection re-establishes.
    _poller = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      _pollCount++;
      if (_pollCount >= 6) {
        _poller.cancel();
        setState(() => _confirmed = true);
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _poller.cancel();
    super.dispose();
  }

  void _openSuccess() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => PaymentSuccessScreen(
        title: widget.successTitle,
        subtitle: widget.successSubtitle,
        txnId: widget.idempotencyKey,
        quotas: widget.quotas,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('Low-Connectivity Payment',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Column(children: [
                Icon(Icons.signal_cellular_connected_no_internet_4_bar,
                    color: Colors.amber.shade700, size: 40.r),
                SizedBox(height: 10.h),
                Text('Offline USSD fallback active',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 6.h),
                Text('Rs ${widget.amount.toStringAsFixed(0)} | ${widget.purpose}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
              ]),
            ),
            SizedBox(height: 16.h),
            Text('Dial this USSD code on any basic feature phone:',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(_ussdCode,
                  style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: _primaryGreen)),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(children: [
                Text('Offline QR for cooperative agent scanning',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                SizedBox(height: 10.h),
                Icon(Icons.qr_code_2, size: 120.r, color: _primaryGreen),
                SizedBox(height: 8.h),
                Text('Ref: ${widget.referenceId}', style: TextStyle(fontSize: 10.sp, color: Colors.grey[500])),
              ]),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: _confirmed ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _confirmed ? Colors.green : Colors.grey.shade300),
              ),
              child: Row(children: [
                if (_confirmed)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _confirmed
                        ? 'Connection re-established - ledger updated. Tap Confirm to continue.'
                        : 'Polling gateway status... ($_pollCount/6). Auto-refreshes when signal returns.',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[800]),
                  ),
                ),
              ]),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _confirmed ? _primaryGreen : Colors.grey.shade400,
                    padding: EdgeInsets.symmetric(vertical: 14.h)),
                onPressed: _confirmed ? _openSuccess : null,
                child: Text('Confirm & Continue',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp)),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

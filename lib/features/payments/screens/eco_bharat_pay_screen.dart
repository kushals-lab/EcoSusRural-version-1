import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'payment_success_screen.dart';
import 'ussd_fallback_screen.dart';

class EcoBharatPayScreen extends StatefulWidget {
  final double amount;
  final String purpose;
  final String referenceId;

  /// Optional checkout context for subscription payments. When provided the
  /// verified payment opens the [PaymentSuccessScreen] (Active Subscription &
  /// Operational Dashboard) instead of the plain success dialog.
  final PaymentSuccessContext? successContext;

  const EcoBharatPayScreen({
    super.key,
    required this.amount,
    required this.purpose,
    required this.referenceId,
    this.successContext,
  });

  @override
  State<EcoBharatPayScreen> createState() => _EcoBharatPayScreenState();
}

/// 5-stage deterministic UI lifecycle for every EcoBharatPay button
/// (Blueprint 5.2). Prevents double-charging on weak connectivity.
enum _PayState { idle, optimisticLock, processing, success, error }

class _EcoBharatPayScreenState extends State<EcoBharatPayScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);
  static const Color _amber = Color(0xFFF59E0B);

  _PayState _state = _PayState.idle;
  String _selectedMethod = 'upi';
  bool _simulateWeakNetwork = false;

  /// Unique idempotency key generated at OPTIMISTIC LOCK (State 2).
  String _idempotencyKey = '';

  String get _stateLabel {
    switch (_state) {
      case _PayState.idle:
        return 'Pay Rs ${widget.amount.toStringAsFixed(2)} via EcoBharatPay';
      case _PayState.optimisticLock:
        return 'Securing Agri-Escrow...';
      case _PayState.processing:
        return 'Routing through Secure Rural Gateway...';
      case _PayState.success:
        return 'Payment Verified!';
      case _PayState.error:
        return 'Network Timeout - Retry or go Offline';
    }
  }

  Color get _stateColor {
    switch (_state) {
      case _PayState.idle:
        return _primaryGreen;
      case _PayState.optimisticLock:
      case _PayState.processing:
        return _amber;
      case _PayState.success:
        return const Color(0xFF2E7D32);
      case _PayState.error:
        return _amber;
    }
  }

  String _generateIdempotencyKey() {
    final rng = Random.secure();
    final digits =
        String.fromCharCodes(Iterable.generate(8, (_) => rng.nextInt(10) + 48));
    return 'TXN$digits${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  /// Simulated authentication step: UPI PIN / biometric / DBT subsidy code.
  Future<bool> _authenticate() async {
    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Authenticate Payment',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Confirm Rs ${widget.amount.toStringAsFixed(2)} for ${widget.purpose}',
              style: TextStyle(fontSize: 13.sp)),
          SizedBox(height: 12.h),
          _authOption(ctx, Icons.dialpad, 'Enter UPI PIN'),
          SizedBox(height: 8.h),
          _authOption(ctx, Icons.fingerprint, 'Biometric confirmation'),
          SizedBox(height: 8.h),
          _authOption(ctx, Icons.redeem, 'Apply Direct Benefit Subsidy (DBT) code'),
        ]),
      ),
    );
    return approved ?? false;
  }

  Widget _authOption(BuildContext ctx, IconData icon, String label) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 44.h),
        side: BorderSide(color: _primaryGreen.withValues(alpha: 0.5)),
      ),
      onPressed: () => Navigator.pop(ctx, true),
      icon: Icon(icon, color: _primaryGreen, size: 18),
      label: Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
    );
  }

  void _processPayment() async {
    // STATE 2: OPTIMISTIC LOCK - lock instantly, generate idempotency key.
    setState(() {
      _state = _PayState.optimisticLock;
      _idempotencyKey = _generateIdempotencyKey();
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // STATE 3: PROCESSING - spinning badge + status message.
    if (!mounted) return;
    setState(() => _state = _PayState.processing);
    final authenticated = await _authenticate();
    if (!mounted) return;
    if (!authenticated) {
      // Cancelled - back to idle without clearing any checkout input.
      setState(() => _state = _PayState.idle);
      return;
    }
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    if (_simulateWeakNetwork) {
      // STATE 5: ERROR RECOVERY - soft amber, inputs preserved, USSD fallback.
      setState(() => _state = _PayState.error);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Network timeout. All checkout details preserved - retry or use the offline USSD protocol.'),
      ));
      return;
    }

    // STATE 4: SUCCESS - flash green, confirm, open the target page.
    setState(() => _state = _PayState.success);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _finishPayment();
  }

  void _finishPayment() {
    final ctx = widget.successContext;
    if (ctx != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          title: ctx.title,
          subtitle: ctx.subtitle,
          txnId: _idempotencyKey,
          quotas: ctx.quotas,
        ),
      ));
      return;
    }
    _showPlainSuccessDialog();
  }

  void _showPlainSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 48.r),
            ),
            SizedBox(height: 16.h),
            Text(
              'Payment Verified!',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Rs ${widget.amount.toStringAsFixed(2)} paid for ${widget.purpose}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 8.h),
            Text(
              'Txn ID: $_idempotencyKey',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () {
                Navigator.pop(ctx); // pop dialog
                Navigator.pop(context, true); // pop screen with success flag
              },
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _retryOfflineUssd() {
    final ctx = widget.successContext;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => UssdFallbackScreen(
        amount: widget.amount,
        purpose: widget.purpose,
        referenceId: widget.referenceId,
        idempotencyKey: _idempotencyKey,
        successTitle: ctx?.title ?? 'Payment Verified!',
        successSubtitle:
            'Rs ${widget.amount.toStringAsFixed(2)} paid for ${widget.purpose} via offline USSD.',
        quotas: ctx?.quotas ?? const [],
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
        title: Text(
          'EcoBharatPay',
          style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Summary Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Amount to Pay',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '₹${widget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            widget.purpose,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[800]),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Ref: ${widget.referenceId}',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 12.h),

                  // Payment Options
                  _buildPaymentOption(
                    id: 'upi',
                    title: 'UPI',
                    subtitle: 'Google Pay, PhonePe, Paytm',
                    icon: Icons.qr_code_scanner,
                  ),
                  SizedBox(height: 12.h),
                  _buildPaymentOption(
                    id: 'card',
                    title: 'Credit / Debit Card',
                    subtitle: 'Visa, MasterCard, RuPay',
                    icon: Icons.credit_card,
                  ),
                  SizedBox(height: 12.h),
                  _buildPaymentOption(
                    id: 'netbanking',
                    title: 'Net Banking',
                    subtitle: 'All Indian banks supported',
                    icon: Icons.account_balance,
                  ),
                  SizedBox(height: 12.h),
                  _buildPaymentOption(
                    id: 'wallet',
                    title: 'Wallets',
                    subtitle: 'Amazon Pay, Mobikwik',
                    icon: Icons.account_balance_wallet,
                  ),
                  SizedBox(height: 12.h),
                  _buildPaymentOption(
                    id: 'emi',
                    title: 'EMI',
                    subtitle: 'Pay in easy installments',
                    icon: Icons.date_range,
                  ),
                  SizedBox(height: 20.h),
                  
                  // Trust badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, size: 16.r, color: Colors.grey[500]),
                      SizedBox(width: 6.w),
                      Text(
                        '100% Secure Payments by EcoBharatPay',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Demo control: simulates a rural weak-network timeout so
                  // the State 5 (ERROR RECOVERY) path can be exercised.
                  InkWell(
                    onTap: () => setState(() => _simulateWeakNetwork = !_simulateWeakNetwork),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _simulateWeakNetwork ? Icons.toggle_on : Icons.toggle_off,
                            color: _simulateWeakNetwork ? Colors.amber.shade800 : Colors.grey,
                            size: 22.r,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Simulate weak network (demo)',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: _simulateWeakNetwork ? Colors.amber.shade800 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          
          // Bottom Pay Button
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _stateColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      // Locked in OPTIMISTIC LOCK / PROCESSING / SUCCESS.
                      onPressed: (_state == _PayState.idle || _state == _PayState.error)
                          ? _processPayment
                          : null,
                      child: (_state == _PayState.optimisticLock || _state == _PayState.processing)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    _stateLabel,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _stateLabel,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                  // STATE 5: offline USSD / retry fallback (never clears form data).
                  if (_state == _PayState.error) ...[
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          // ignore: prefer_const_constructors
                          side: BorderSide(color: _amber),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: _retryOfflineUssd,
                        icon: const Icon(Icons.sms_outlined, color: _amber, size: 18),
                        label: const Text(
                          'Retry via Offline USSD / Fallback',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _amber),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == id;
    
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGreen.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? _primaryGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isSelected ? _primaryGreen.withValues(alpha: 0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24.r,
                color: isSelected ? _primaryGreen : Colors.grey[600],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? _primaryGreen : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

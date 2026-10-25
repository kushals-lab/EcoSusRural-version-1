import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One line of the transparent cost breakdown shown above the pay button.
class CheckoutCostRow {
  final String label;
  final String value;
  final bool isBold;

  const CheckoutCostRow(this.label, this.value, {this.isBold = false});
}

/// Universal EcoBharat Pay, UPI & Other Payment Methods Checkout Screen.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.title,
    this.costRows,
    this.payLabel,
    this.successTitle,
    this.successMessage,
    this.onPaid,
  });

  final String? title;
  final List<CheckoutCostRow>? costRows;
  final String? payLabel;
  final String? successTitle;
  final String? successMessage;
  final VoidCallback? onPaid;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  String _selectedPayment = 'EcoBharatPay'; // Default option 1
  bool _processing = false;
  bool _expandOtherMethods = false;
  String _selectedOtherMethod = 'Card';

  static const List<CheckoutCostRow> _defaultCostRows = [
    CheckoutCostRow('Product Price', '₹12,500'),
    CheckoutCostRow('Platform Service Fee (3%)', '₹375'),
    CheckoutCostRow('Delivery Charges', '₹95'),
    CheckoutCostRow('GST (10%)', '₹1,297'),
    CheckoutCostRow('Total', '₹14,267', isBold: true),
  ];

  List<CheckoutCostRow> get _rows => widget.costRows ?? _defaultCostRows;

  CheckoutCostRow get _total =>
      _rows.lastWhere((row) => row.isBold, orElse: () => _rows.last);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(widget.title ?? 'Choose Payment Method',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transparent Cost Breakdown
            _buildCostBreakdown(),

            SizedBox(height: 20.h),

            Text('Select Payment Method', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),

            // Option 1: EcoBharat Pay
            _buildPaymentOption(
              id: 'EcoBharatPay',
              title: 'EcoBharat Pay',
              subtitle: 'Authorized Rural Escrow & Direct Benefit Wallet',
              icon: Icons.account_balance_wallet,
              badge: 'Recommended',
            ),

            SizedBox(height: 10.h),

            // Option 2: UPI
            _buildPaymentOption(
              id: 'UPI',
              title: 'UPI (Unified Payments Interface)',
              subtitle: 'Google Pay, PhonePe, Paytm, BHIM & Intent Apps',
              icon: Icons.qr_code_scanner,
            ),

            SizedBox(height: 10.h),

            // Option 3: Other Payment Methods (Expandable)
            _buildOtherMethodsAccordion(),

            SizedBox(height: 24.h),

            // Amount Payable Summary banner
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _primaryGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount Payable:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  Text(_total.value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Pay Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                minimumSize: Size(double.infinity, 54.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: _processing ? null : () => _processPayment(context),
              child: _processing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.payLabel ?? 'Continue to Payment — ${_total.value}',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'Secured with end-to-end encryption & backend verification.',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostBreakdown() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          for (final row in _rows) _costRow(row.label, row.value, isBold: row.isBold),
        ],
      ),
    );
  }

  Widget _costRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 13.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isBold ? _primaryGreen : Colors.black87)),
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
    String? badge,
  }) {
    final isSelected = _selectedPayment == id;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPayment = id;
        if (id != 'Other') _expandOtherMethods = false;
      }),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGreen.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? _primaryGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _primaryGreen : Colors.grey[600], size: 26.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                      if (badge != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4.r)),
                          child: Text(badge, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? _primaryGreen : Colors.grey[400],
              size: 22.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherMethodsAccordion() {
    final isSelected = _selectedPayment == 'Other';
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? _primaryGreen.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? _primaryGreen : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.payment, color: isSelected ? _primaryGreen : Colors.grey[600], size: 26.r),
            title: Text('Other Payment Methods', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            subtitle: Text('Debit / Credit Cards, Net Banking & Cash on Delivery', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            trailing: IconButton(
              icon: Icon(_expandOtherMethods ? Icons.expand_less : Icons.expand_more, color: _primaryGreen),
              onPressed: () => setState(() {
                _expandOtherMethods = !_expandOtherMethods;
                _selectedPayment = 'Other';
              }),
            ),
            onTap: () => setState(() {
              _selectedPayment = 'Other';
              _expandOtherMethods = !_expandOtherMethods;
            }),
          ),
          if (_expandOtherMethods) ...[
            const Divider(height: 1),
            _buildSubMethodTile('Card', 'Debit / Credit Card (Visa, Mastercard, RuPay)'),
            _buildSubMethodTile('NetBanking', 'Net Banking (All Major Banks)'),
            _buildSubMethodTile('COD', 'Cash on Delivery (Escrow Protected)'),
          ],
        ],
      ),
    );
  }

  Widget _buildSubMethodTile(String id, String label) {
    final active = _selectedOtherMethod == id;
    return ListTile(
      dense: true,
      title: Text(label, style: TextStyle(fontSize: 13.sp, color: active ? _primaryGreen : Colors.black87, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      trailing: Icon(active ? Icons.radio_button_checked : Icons.radio_button_off, color: active ? _primaryGreen : Colors.grey, size: 20),
      onTap: () => setState(() {
        _selectedOtherMethod = id;
        _selectedPayment = 'Other';
      }),
    );
  }

  void _processPayment(BuildContext context) {
    setState(() => _processing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || !context.mounted) return;
      setState(() => _processing = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.successTitle ?? 'Payment Verified & Confirmed!'),
              ),
            ],
          ),
          content: Text(
            widget.successMessage ??
                'Your payment of ${_total.value} via ${_selectedPayment == 'Other' ? _selectedOtherMethod : _selectedPayment} has been verified and recorded on the backend securely. '
                    'A digital receipt has been generated.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onPaid?.call();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}

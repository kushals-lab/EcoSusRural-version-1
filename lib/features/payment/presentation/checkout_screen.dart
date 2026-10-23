import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One line of the transparent cost breakdown shown above the pay button.
class CheckoutCostRow {
  final String label;
  final String value;
  final bool isBold;

  const CheckoutCostRow(this.label, this.value, {this.isBold = false});
}

/// EcoBharatPay checkout.
///
/// Used by the marketplace cart by default; scheme applications reuse the same
/// payment section by passing a [title], [costRows] and an [onPaid] callback
/// (every other argument keeps the marketplace behaviour untouched).
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

  /// Called after the payment dialog is dismissed (fee recorded, next screen).
  final VoidCallback? onPaid;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  String _selectedPayment = 'UPI';
  bool _processing = false;

  static const List<CheckoutCostRow> _defaultCostRows = [
    CheckoutCostRow('Product Price', '₹12,500'),
    CheckoutCostRow('Platform Service Fee (3%)', '₹375'),
    CheckoutCostRow('Delivery Charges', '₹95'),
    CheckoutCostRow('GST (10%)', '₹1,297'),
    CheckoutCostRow('Total', '₹14,267', isBold: true),
  ];

  List<CheckoutCostRow> get _rows => widget.costRows ?? _defaultCostRows;

  /// The bold row is always the payable total.
  CheckoutCostRow get _total =>
      _rows.lastWhere((row) => row.isBold, orElse: () => _rows.last);

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'UPI', 'label': 'UPI', 'icon': Icons.qr_code, 'subtitle': 'GPay, PhonePe, Paytm, BHIM'},
    {'id': 'Wallet', 'label': 'EcoSusRural Wallet', 'icon': Icons.account_balance_wallet, 'subtitle': '₹250 balance available'},
    {'id': 'Card', 'label': 'Debit / Credit Card', 'icon': Icons.credit_card, 'subtitle': 'Visa, Mastercard, RuPay'},
    {'id': 'NetBanking', 'label': 'Net Banking', 'icon': Icons.account_balance, 'subtitle': 'All major Indian banks'},
    {'id': 'COD', 'label': 'Cash on Delivery', 'icon': Icons.local_shipping, 'subtitle': 'Escrow-protected payout'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(widget.title ?? 'Checkout',
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

            Text('Payment Method', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),
            ..._paymentMethods.map((method) => _buildPaymentOption(method)),

            SizedBox(height: 24.h),

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
                  : Text(widget.payLabel ?? 'Pay ${_total.value} / भुगतान करें',
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'You will be asked to confirm this charge before any amount is deducted.',
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

  Widget _buildPaymentOption(Map<String, dynamic> method) {
    final isSelected = _selectedPayment == method['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = method['id']),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
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
            Icon(method['icon'], color: isSelected ? _primaryGreen : Colors.grey[600], size: 26.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method['label'],
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text(method['subtitle'], style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
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
                child: Text(widget.successTitle ?? 'Order Confirmed!'),
              ),
            ],
          ),
          content: Text(
            widget.successMessage ??
                'Your order has been placed successfully. A confirmation has been sent to your email and SMS. '
                    'Track your order from the Marketplace.',
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

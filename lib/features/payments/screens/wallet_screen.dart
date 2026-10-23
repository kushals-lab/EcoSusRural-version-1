import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';
import 'eco_bharat_pay_screen.dart';
import 'payment_links_screen.dart';
import 'payment_success_screen.dart';
import 'transfer_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.tr;
    const Color primaryGreen = Color(0xFF1B4D3E);
    const Color blue = Color(0xFF1A73E8);
    const String ecoBharatPay = 'EcoBharatPay';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(ecoBharatPay, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 20.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: 180.h,
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primaryGreen, Color(0xFF2E7D3E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('totalBalance'), style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
              SizedBox(height: 8.h),
              Text(tr('balanceAmount'), style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 4.h),
              Text(tr('pendingAmount'), style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              SizedBox(height: 16.h),
              Text(tr('availableAmount'), style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(tr('available'), style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                Icon(Icons.visibility_off, color: Colors.white70, size: 20.sp),
              ]),
            ]),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text(tr('quickActions'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)))),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(spacing: 12.w, runSpacing: 12.h, children: [
              _QuickAction(icon: Icons.send, label: tr('transfer'), color: blue, onTap: () => _openTransfer(context)),
              _QuickAction(icon: Icons.qr_code_scanner, label: tr('scan'), color: const Color(0xFF007AFF), onTap: () => _openTransfer(context)),
              _QuickAction(icon: Icons.payment, label: tr('request'), color: Colors.orange, onTap: () => _openPaymentLinks(context)),
              _QuickAction(icon: Icons.account_balance, label: tr('addMoney'), color: primaryGreen, onTap: () => _openWalletTopUp(context)),
            ]),
          ),
          SizedBox(height: 8.h),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), child: Text(tr('transactions'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 5,
            itemBuilder: (context, i) => ListTile(
              leading: CircleAvatar(radius: 20.r, backgroundColor: Colors.grey[200], child: Icon(Icons.currency_rupee, color: Colors.grey[600], size: 20.sp)),
              title: Text('Payment received', style: TextStyle(fontSize: 14.sp)),
              subtitle: Text('Mar 15, 2024', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              trailing: Text('-Rs 250.00', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTransfer(context),
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.qr_code, color: Colors.white),
        label: Text(tr('scanPay'), style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _openTransfer(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()));
  }

  void _openPaymentLinks(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentLinksScreen()));
  }

  void _openWalletTopUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EcoBharatPayScreen(
          amount: 500,
          purpose: 'Wallet Top-up',
          referenceId: 'WAL-${DateTime.now().millisecondsSinceEpoch}',
          successContext: const PaymentSuccessContext(
            title: 'Wallet Top-up Successful',
            subtitle: 'Your EcoBharatPay wallet has been funded successfully.',
            quotas: [
              SubscriptionQuotaSummary(label: 'Wallet Balance', value: '₹500.00', fraction: 0.5, icon: Icons.account_balance_wallet),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.w,
      child: Column(children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: 60.w, height: 60.w,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24.sp),
          ),
        ),
        SizedBox(height: 4.h),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
      ]),
    );
  }
}

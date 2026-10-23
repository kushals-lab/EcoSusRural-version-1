
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class PaymentLinksScreen extends ConsumerStatefulWidget {
  const PaymentLinksScreen({super.key});
  @override
  ConsumerState<PaymentLinksScreen> createState() => _PaymentLinksScreenState();
}

class _PaymentLinksScreenState extends ConsumerState<PaymentLinksScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(tr('paymentLinks'), style: const TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(tr('createLink'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          TextField(controller: _amountController, decoration: InputDecoration(labelText: tr('amount'), hintText: 'Rs 500', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))), keyboardType: TextInputType.number),
          SizedBox(height: 12.h),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(labelText: tr('note'), hintText: tr('addNote'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
            maxLines: 3,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(onPressed: _amountController.text.isNotEmpty ? _createLink : null, child: Text(tr('generateLink'), style: TextStyle(fontSize: 16.sp))),
          SizedBox(height: 16.h),
          Text(tr('yourLinks'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 2, itemBuilder: (context, i) => ListTile(
            leading: Icon(Icons.link, color: const Color(0xFF2E7D3E), size: 24.sp),
            title: Text('Rs 500 - For seeds', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('Created Mar 15, 2024', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
            trailing: Icon(Icons.qr_code, color: const Color(0xFF2E7D3E), size: 20.sp),
            onTap: () {},
          )),
        ])),
      ),
    );
  }

  void _createLink() {}
}

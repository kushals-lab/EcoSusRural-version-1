
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});
  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
        title: Text(tr('transfer'), style: const TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: TextField(controller: _phoneController, decoration: InputDecoration(hintText: tr('enterPhone'), hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp), border: InputBorder.none, prefixIcon: const Icon(Icons.phone, color: Color(0xFF2E7D3E))), keyboardType: TextInputType.phone)),
          SizedBox(height: 16.h),
          Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: TextField(controller: _amountController, decoration: InputDecoration(labelText: tr('amount'), hintText: 'Rs 500', border: InputBorder.none, prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF2E7D3E))), keyboardType: TextInputType.number)),
          SizedBox(height: 12.h),
          Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: TextField(controller: _noteController, decoration: InputDecoration(labelText: tr('note'), hintText: tr('addNote'), border: InputBorder.none), maxLines: 3)),
          SizedBox(height: 16.h),
          _buildContactChips(),
          SizedBox(height: 16.h),
          ElevatedButton(onPressed: _phoneController.text.isNotEmpty && _amountController.text.isNotEmpty ? _transfer : null, child: Text(tr('sendMoney'), style: TextStyle(fontSize: 16.sp))),
        ])),
      ),
    );
  }

  Widget _buildContactChips() {
    final contacts = [
      Contact(name: 'Ramesh Farmer', phone: '9876543210'),
      Contact(name: 'Priya Organic', phone: '9876543211'),
    ];
    return Wrap(spacing: 8.w, runSpacing: 8.h, children: contacts.map((c) => ChoiceChip(label: Text(c.name, style: TextStyle(fontSize: 11.sp)), selected: false, onSelected: (_) => setState(() => _phoneController.text = c.phone))).toList());
  }

  void _transfer() {}
}

class Contact {
  final String name;
  final String phone;
  Contact({required this.name, required this.phone});
}

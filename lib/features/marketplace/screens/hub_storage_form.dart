/// Storage + lab booking form: item, days, per-day charge, expected bill,
/// plus packaging-material shopping list.
library hub_storage_form;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/processing_models.dart';
import 'hub_detail_widgets.dart';
class StorageLabForm extends StatefulWidget {
  const StorageLabForm({super.key});

  @override
  State<StorageLabForm> createState() => _StorageLabFormState();
}

class _StorageLabFormState extends State<StorageLabForm> {
  final TextEditingController _itemCtrl =
      TextEditingController(text: 'Dried mango pouches');
  final TextEditingController _daysCtrl = TextEditingController(text: '30');
  final TextEditingController _rateCtrl = TextEditingController(text: '45');
  final TextEditingController _packCtrl = TextEditingController(text: '1200');
  final Map<String, bool> _packaging = {
    'Moisture-seal pouches': true,
    'Compostable kraft boxes': false,
    'Paper tape + jute filler': false,
    'Silica sachets (food-grade)': true,
  };

  @override
  void dispose() {
    _itemCtrl.dispose();
    _daysCtrl.dispose();
    _rateCtrl.dispose();
    _packCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = int.tryParse(_daysCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    final pack = double.tryParse(_packCtrl.text.trim()) ?? 0;
    final bill = StorageBooking(
      itemName: _itemCtrl.text.trim(),
      days: days,
      perDayCharge: rate,
      packagingCost: pack,
    ).expectedBill;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect with storage & labs — booking form',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900)),
        SizedBox(height: 8.h),
        TextField(
          controller: _itemCtrl,
          decoration: const InputDecoration(
              labelText: 'Which items (e.g. dried mango, onion flakes)',
              border: OutlineInputBorder()),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'No. of days',
                    border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: _rateCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Per-day charge (Rs)',
                    border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _packCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
              labelText: 'Packaging material cost (Rs)',
              border: OutlineInputBorder()),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        Text('Packaging material shopping',
            style: TextStyle(
                fontSize: 13.sp, fontWeight: FontWeight.bold)),
        ..._packaging.keys.map((item) => CheckboxListTile(
              value: _packaging[item],
              activeColor: kHubGreen,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(item, style: TextStyle(fontSize: 12.sp)),
              onChanged: (v) =>
                  setState(() => _packaging[item] = v ?? false),
            )),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: kHubGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: kHubGreen.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Expected bill: Rs ${bill.toStringAsFixed(0)} '
            '($days days x Rs ${rate.toStringAsFixed(0)}/day + Rs ${pack.toStringAsFixed(0)} packaging).',
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: kHubGreen),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kHubGreen,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Booking request saved for ${_itemCtrl.text.trim().isEmpty ? 'your items' : _itemCtrl.text.trim()} — Rs ${bill.toStringAsFixed(0)}. Lab will confirm slot.')),
              );
            },
            icon: const Icon(Icons.warehouse_outlined, color: Colors.white),
            label: const Text('Submit storage + lab request',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

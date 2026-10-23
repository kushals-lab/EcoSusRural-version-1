
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class TrainSearchScreen extends ConsumerStatefulWidget {
  const TrainSearchScreen({super.key});
  @override ConsumerState<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends ConsumerState<TrainSearchScreen> {
  String _from = ''; String _to = '';
  final DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(tr('trains'), style: const TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _buildField(tr('fromStation'), (v) => setState(() => _from = v)),
          SizedBox(height: 12.h),
          _buildField(tr('toStation'), (v) => setState(() => _to = v)),
          SizedBox(height: 12.h),
          Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 12.w), title: Text(tr('journeyDate'), style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)), subtitle: Text(_date.toIso8601String().split('T').first, style: TextStyle(color: Colors.black87, fontSize: 14.sp)), trailing: const Icon(Icons.calendar_today, color: Color(0xFF2E7D3E)), onTap: () {})),
          SizedBox(height: 16.h),
          Text(tr('travelClass'), style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Wrap(spacing: 8.w, children: [
            _C(label: tr('sleeper'), sel: true), _C(label: tr('ac3Tier'), sel: false),
            _C(label: tr('ac2Tier'), sel: false), _C(label: tr('ac1Tier'), sel: false),
            _C(label: tr('firstClass'), sel: false),
          ]),
          SizedBox(height: 24.h),
          ElevatedButton(onPressed: _from.isNotEmpty && _to.isNotEmpty ? () {} : null, child: Text(tr('searchTrains'), style: TextStyle(fontSize: 16.sp))),
          SizedBox(height: 24.h),
          Text(tr('popularRoutes'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 3, itemBuilder: (context, i) => ListTile(
            leading: Icon(Icons.train, color: const Color(0xFF2E7D3E), size: 24.sp),
            title: Text('Mumbai - Delhi Rajdhani', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text('17:45 - 08:30 (+1day)', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
            trailing: const Text('Rs 1,850', style: TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
          )),
        ])),
      ),
    );
  }

  Widget _buildField(String label, Function(String) onChanged) {
    final tr = ref.tr;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
      SizedBox(height: 4.h),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: tr('enterStation'),
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D3E)),
          ),
          onChanged: onChanged,
        ),
      ),
    ]);
  }
}

class _C extends StatelessWidget {
  final String label; final bool sel;
  const _C({required this.label, required this.sel});
  @override Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label, style: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12.sp)), selected: sel, onSelected: (_) {}, backgroundColor: Colors.grey[200], selectedColor: const Color(0xFF2E7D3E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)));
  }
}

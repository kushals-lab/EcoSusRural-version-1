
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class DoctorSearchScreen extends ConsumerStatefulWidget {
  const DoctorSearchScreen({super.key});
  @override ConsumerState<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends ConsumerState<DoctorSearchScreen> {
  String _specialty = '';
  String _location = '';

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(tr('health'), style: const TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(tr('specialty'), style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: TextField(decoration: InputDecoration(hintText: tr('enterSpecialty'), hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp), border: InputBorder.none, prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D3E))), onChanged: (v) => setState(() => _specialty = v))),
          SizedBox(height: 12.h),
          Text(tr('location'), style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: TextField(decoration: InputDecoration(hintText: tr('enterLocation'), hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp), border: InputBorder.none, prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2E7D3E))), onChanged: (v) => setState(() => _location = v))),
          SizedBox(height: 16.h),
          ElevatedButton(onPressed: _specialty.isNotEmpty && _location.isNotEmpty ? () {} : null, child: Text(tr('searchDoctors'), style: TextStyle(fontSize: 16.sp))),
          SizedBox(height: 24.h),
          Text(tr('topDoctors'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          ListTile(leading: CircleAvatar(radius: 24.r, backgroundColor: Colors.grey[300], child: Icon(Icons.person, color: Colors.grey[600], size: 30.sp)), title: Text('Dr. Meera Sharma', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)), subtitle: Text('General Physician', style: TextStyle(color: Colors.grey[600])), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)), Icon(Icons.star, color: Colors.yellow, size: 14.sp)])),
          ListTile(leading: CircleAvatar(radius: 24.r, backgroundColor: Colors.grey[300], child: Icon(Icons.person, color: Colors.grey[600], size: 30.sp)), title: Text('Dr. Rajesh Kumar', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)), subtitle: Text('Pediatrician', style: TextStyle(color: Colors.grey[600])), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('4.7', style: TextStyle(fontWeight: FontWeight.bold)), Icon(Icons.star, color: Colors.yellow, size: 14.sp)])),
        ])),
      ]),
    );
  }
}

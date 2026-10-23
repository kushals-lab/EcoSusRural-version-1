import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class RestaurantListingScreen extends ConsumerWidget {
  const RestaurantListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.tr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(tr('food'), style: TextStyle(color: const Color(0xFF2E7D3E), fontWeight: FontWeight.bold, fontSize: 20.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: TextField(decoration: InputDecoration(hintText: tr('searchRestaurants'), hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp), border: InputBorder.none, prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D3E))))),
          SizedBox(height: 16.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: [
            _Chip(tr('all')), _Chip(tr('veg')), _Chip(tr('nonVeg')), _Chip(tr('desserts')), _Chip(tr('drinks')),
          ]),
          SizedBox(height: 16.h),
          Text(tr('nearbyRestaurants'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 4, itemBuilder: (context, i) => Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), child: ListTile(contentPadding: EdgeInsets.all(12.w), leading: Container(width: 60.w, height: 60.w, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8.r)), child: const Icon(Icons.restaurant, color: Colors.grey, size: 30)), title: Text('Green Leaf Cafe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Organic cafe', style: TextStyle(color: Colors.grey, fontSize: 12.sp)), const Wrap(children: [Icon(Icons.star, color: Colors.yellow, size: 14), Text(' 4.6 (128)')])]), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Rs 250', style: TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)), Text('30 min', style: TextStyle(color: Colors.grey, fontSize: 12.sp))]), onTap: () {}))),
        ])),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);
  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF2E7D3E))), backgroundColor: const Color(0xFF2E7D3E).withValues(alpha: 0.1), padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h));
  }
}

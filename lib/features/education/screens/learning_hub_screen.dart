import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class LearningHubScreen extends ConsumerWidget {
  const LearningHubScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.tr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(tr('learn'), style: const TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(decoration: InputDecoration(hintText: tr('searchCourses'), hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D3E)))),
          SizedBox(height: 16.h),
          Text(tr('categories'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: [
            _Cat(Icons.eco, tr('farming')),
            _Cat(Icons.business_center, tr('business')),
            _Cat(Icons.medical_services, tr('healthEdu')),
            _Cat(Icons.local_library, tr('literacy')),
            _Cat(Icons.design_services, tr('crafts')),
          ]),
          SizedBox(height: 16.h),
          Text(tr('recommendedCourses'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, i) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                    ),
                    child: Icon(Icons.play_circle_fill, color: Colors.grey[500], size: 40.sp),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sustainable Farming', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        Text('Climate-resilient methods', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('4.5 hrs', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                            const Text('Free', style: TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ])),
      ),
    );
  }
}

class _Cat extends StatelessWidget {
  final IconData icon; final String label;
  const _Cat(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, decoration: BoxDecoration(color: const Color(0xFF2E7D3E).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF2E7D3E), size: 28.sp), SizedBox(height: 4.h), Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF2E7D3E), fontWeight: FontWeight.w600))]));
  }
}

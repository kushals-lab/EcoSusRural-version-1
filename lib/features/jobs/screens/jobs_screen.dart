import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.tr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(tr('jobs'), style: const TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: EdgeInsets.all(16.w), child: TextField(decoration: InputDecoration(hintText: tr('searchJobs'), hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D3E))))),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 5,
            itemBuilder: (context, i) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.w),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Farm Worker - Harvest Season',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text('Green Valley Farms, Nashik',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                    SizedBox(height: 8.h),
                    Row(children: [
                      CircleAvatar(radius: 12.r, backgroundColor: Colors.grey[300], child: Icon(Icons.currency_rupee, color: Colors.grey[600], size: 14.sp)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(' 12,000 /month',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: const Color(0xFF2E7D3E), fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      ),
                    ]),
                    SizedBox(height: 8.h),
                    Row(children: [
                      Icon(Icons.access_time, color: Colors.grey[600], size: 14.sp),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text('Full-time, Seasonal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                      ),
                    ]),
                  ],
                ),
                subtitle: Text('Posted 2 days ago', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 11.sp)),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                onTap: () {},
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

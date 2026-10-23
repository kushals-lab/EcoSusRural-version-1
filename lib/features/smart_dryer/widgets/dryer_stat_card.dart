/// Small stat card used by the dryer dashboard.
library;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class DryerStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool stale;
  const DryerStatCard({super.key, required this.label,
    required this.value, required this.icon,
    required this.color, this.stale = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: stale ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 6.w),
            Expanded(child: Text(label,
                style: TextStyle(fontSize: 11.sp,
                    color: Colors.grey[700]))),
          ]),
          SizedBox(height: 6.h),
          Text(value, style: TextStyle(fontSize: 17.sp,
              fontWeight: FontWeight.bold)),
          if (stale)
            Text('stale', style: TextStyle(fontSize: 10.sp,
                color: Colors.orange[800],
                fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

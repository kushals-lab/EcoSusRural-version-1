import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/learning_provider.dart';

class CourseLearningScreen extends ConsumerWidget {
  final String courseId;
  const CourseLearningScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(learningProvider);
    final course = courses.firstWhere((c) => c.id == courseId, orElse: () => courses.first);
    const primaryGreen = Color(0xFF1B4D3E);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(course.title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: primaryGreen)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B4D3E)]),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(course.icon, style: TextStyle(fontSize: 32.sp)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.category, style: TextStyle(fontSize: 11.sp, color: Colors.white70, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2.h),
                            Text(course.title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text('Instructor: ${course.instructor}', style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
                  Text('Format: ${course.deliveryMode}', style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: LinearProgressIndicator(value: course.progress, color: Colors.amber, backgroundColor: Colors.white24, minHeight: 8.h),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text('${(course.progress * 100).toInt()}% Completed', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
            Text('Course Description', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: primaryGreen)),
            SizedBox(height: 8.h),
            Text(course.description, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800, height: 1.4)),

            if (course.isCompleted && course.certificateReference != null) ...[
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.amber.shade300)),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.amber, size: 36),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Course Completed!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                          SizedBox(height: 2.h),
                          Text('Certificate Ref: ${course.certificateReference}', style: TextStyle(fontSize: 11.sp, color: Colors.brown.shade700)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('EcoSusRural Certificate'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, color: primaryGreen, size: 48),
                                SizedBox(height: 12.h),
                                Text('Certificate of Completion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                SizedBox(height: 8.h),
                                Text('This certifies that you have successfully completed "${course.title}" under ${course.instructor}.', textAlign: TextAlign.center),
                                SizedBox(height: 8.h),
                                Text('Ref: ${course.certificateReference}', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                      child: const Text('View Cert'),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24.h),
            Text('Modules & Lessons', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: primaryGreen)),
            SizedBox(height: 12.h),

            for (final mod in course.modules)
              Container(
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade300)),
                child: ExpansionTile(
                  title: Text(mod.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  children: [
                    for (final lesson in mod.lessons)
                      CheckboxListTile(
                        activeColor: primaryGreen,
                        title: Text(lesson.title, style: TextStyle(fontSize: 13.sp)),
                        subtitle: Text('${lesson.duration} • ${lesson.contentSummary}', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                        value: lesson.isCompleted,
                        onChanged: (_) {
                          ref.read(learningProvider.notifier).toggleLesson(course.id, lesson.id);
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

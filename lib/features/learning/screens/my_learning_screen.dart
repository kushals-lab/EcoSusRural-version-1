import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/learning_provider.dart';
import 'course_learning_screen.dart';

class MyLearningScreen extends ConsumerWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(learningProvider);
    final enrolledCourses = courses.where((c) => c.isEnrolled).toList();
    const primaryGreen = Color(0xFF1B4D3E);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('My Learning Dashboard', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryGreen)),
        centerTitle: true,
      ),
      body: enrolledCourses.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16.h),
                    Text('No enrolled courses yet.', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    SizedBox(height: 8.h),
                    const Text('Explore the Learning Academy and enroll in sustainable agriculture, artisan craft, or export readiness courses.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: enrolledCourses.length,
              itemBuilder: (context, index) {
                final course = enrolledCourses[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(course.icon, style: TextStyle(fontSize: 28.sp)),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                SizedBox(height: 2.h),
                                Text('${course.category} • ${course.duration}', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: LinearProgressIndicator(value: course.progress, color: primaryGreen, backgroundColor: Colors.grey.shade200, minHeight: 6.h),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text('${(course.progress * 100).toInt()}%', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryGreen)),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => CourseLearningScreen(courseId: course.id)));
                          },
                          child: Text(course.isCompleted ? 'Review & Certificate' : 'Continue Learning'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

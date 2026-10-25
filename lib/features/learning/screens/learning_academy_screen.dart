import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../marketplace/screens/offline_workspace_screen.dart';
import '../../payment/presentation/checkout_screen.dart';
import '../providers/learning_provider.dart';
import 'course_learning_screen.dart';
import 'my_learning_screen.dart';

class LearningAcademyScreen extends ConsumerStatefulWidget {
  const LearningAcademyScreen({super.key});

  @override
  ConsumerState<LearningAcademyScreen> createState() => _LearningAcademyScreenState();
}

class _LearningAcademyScreenState extends ConsumerState<LearningAcademyScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Farming', 'Artisan', 'Marketing', 'Financial', 'Trade', 'Sustainability'];

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(learningProvider);
    final filteredCourses = _selectedCategory == 'All'
        ? courses
        : courses.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Learning Academy',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'My Learning Dashboard',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyLearningScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.offline_pin),
            tooltip: 'Offline learning library',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineWorkspaceScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 44.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: _primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 13.sp,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = category),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                return _CourseCard(course: course);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.course});
  final CourseDetail course;
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _categoryColor(course.category).withValues(alpha: 0.15),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Stack(
              children: [
                Center(child: Text(course.icon, style: TextStyle(fontSize: 44.sp))),
                Positioned(
                  top: 8.r,
                  right: 8.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: course.isPremium ? Colors.amber.shade600 : _primaryGreen,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      course.isPremium ? 'PREMIUM (₹${course.price.toInt()})' : 'FREE',
                      style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4.w),
                    Text(course.instructor, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${course.duration} • ${course.totalLessons} lessons • ${course.deliveryMode}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
                    ),
                    SizedBox(width: 6.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: course.isEnrolled ? Colors.green.shade700 : _primaryGreen,
                        minimumSize: Size(80.w, 32.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                      onPressed: () {
                        if (course.isEnrolled) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CourseLearningScreen(courseId: course.id)));
                        } else if (course.isPremium) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                title: 'Enroll in ${course.title}',
                                costRows: [
                                  CheckoutCostRow('Course Fee', '₹${course.price.toInt()}'),
                                  const CheckoutCostRow('Platform Access', '₹0'),
                                  CheckoutCostRow('Total Payable', '₹${course.price.toInt()}', isBold: true),
                                ],
                                successTitle: 'Enrollment Confirmed!',
                                successMessage: 'Payment verified via EcoBharat Pay. You now have full access to ${course.title}.',
                                onPaid: () {
                                  ref.read(learningProvider.notifier).enroll(course.id);
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => CourseLearningScreen(courseId: course.id)));
                                },
                              ),
                            ),
                          );
                        } else {
                          ref.read(learningProvider.notifier).enroll(course.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully Enrolled!')));
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CourseLearningScreen(courseId: course.id)));
                        }
                      },
                      child: Text(course.isEnrolled ? 'Enrolled' : 'Enroll', style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Farming':
        return const Color(0xFF2E7D32);
      case 'Artisan':
        return const Color(0xFF1565C0);
      case 'Marketing':
        return const Color(0xFF7B1FA2);
      case 'Financial':
        return const Color(0xFFF57C00);
      case 'Trade':
        return const Color(0xFF00695C);
      case 'Sustainability':
        return const Color(0xFF558B2F);
      default:
        return const Color(0xFF455A64);
    }
  }
}

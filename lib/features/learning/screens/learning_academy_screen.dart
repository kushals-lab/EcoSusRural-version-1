import '../../marketplace/screens/offline_workspace_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final String duration;
  final int lessons;
  final bool isPremium;
  final String icon;
  final bool isDRMProtected;

  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.duration,
    required this.lessons,
    required this.icon,
    this.isPremium = false,
    this.isDRMProtected = true,
  });
}

const List<CourseModel> kCourses = [
  CourseModel(
    id: 'c1',
    title: 'Product Photography for Rural Products',
    instructor: 'Ananya Sharma',
    category: 'Marketing',
    duration: '2h 30m',
    lessons: 8,
    icon: '📸',
  ),
  CourseModel(
    id: 'c2',
    title: 'Organic Farming Certification Process',
    instructor: 'ICAR Institute',
    category: 'Farming',
    duration: '3h 15m',
    lessons: 12,
    icon: '🌱',
  ),
  CourseModel(
    id: 'c3',
    title: 'Digital Payments & Banking Basics',
    instructor: 'RBI Edu Team',
    category: 'Financial',
    duration: '1h 45m',
    lessons: 6,
    icon: '💰',
  ),
  CourseModel(
    id: 'c4',
    title: 'Handicraft Quality Standards & Finishing',
    instructor: 'Master Artisan Kailash',
    category: 'Artisan',
    duration: '4h',
    lessons: 15,
    icon: '🎨',
    isPremium: true,
  ),
  CourseModel(
    id: 'c5',
    title: 'Export Documentation & Procedures',
    instructor: 'DGFT Expert',
    category: 'Trade',
    duration: '2h',
    lessons: 7,
    icon: '🌍',
    isPremium: true,
  ),
  CourseModel(
    id: 'c6',
    title: 'Sustainable Packaging & Eco Practices',
    instructor: 'GreenPack Collective',
    category: 'Sustainability',
    duration: '1h 30m',
    lessons: 5,
    icon: '♻️',
  ),
];

class LearningAcademyScreen extends StatefulWidget {
  const LearningAcademyScreen({super.key});

  @override
  State<LearningAcademyScreen> createState() => _LearningAcademyScreenState();
}

class _LearningAcademyScreenState extends State<LearningAcademyScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Farming', 'Artisan', 'Marketing', 'Financial', 'Trade', 'Sustainability'];

  @override
  Widget build(BuildContext context) {
    final courses = _selectedCategory == 'All'
        ? kCourses
        : kCourses.where((c) => c.category == _selectedCategory).toList();

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
        actions: [IconButton(icon: const Icon(Icons.offline_pin), tooltip: 'Offline learning library', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineWorkspaceScreen())))],
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
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return _CourseCard(course: course);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final CourseModel course;
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
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
                      course.isPremium ? 'PREMIUM' : 'FREE',
                      style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (course.isDRMProtected)
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Icon(Icons.lock, color: Colors.black45, size: 18),
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
                      child: Text('${course.duration} • ${course.lessons} lessons',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                    ),
                    SizedBox(width: 6.w),
                    Text('Enroll',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: _primaryGreen, fontWeight: FontWeight.bold)),
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

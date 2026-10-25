import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseLesson {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;
  final String contentSummary;
  bool isCompleted;

  CourseLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    required this.contentSummary,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'videoUrl': videoUrl,
        'contentSummary': contentSummary,
        'isCompleted': isCompleted,
      };

  factory CourseLesson.fromJson(Map<String, dynamic> json) => CourseLesson(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        duration: json['duration'] ?? '15m',
        videoUrl: json['videoUrl'] ?? '',
        contentSummary: json['contentSummary'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
      );
}

class CourseModule {
  final String title;
  final List<CourseLesson> lessons;

  CourseModule({required this.title, required this.lessons});

  Map<String, dynamic> toJson() => {
        'title': title,
        'lessons': lessons.map((l) => l.toJson()).toList(),
      };

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
        title: json['title'] ?? '',
        lessons: (json['lessons'] as List? ?? []).map((l) => CourseLesson.fromJson(l)).toList(),
      );
}

class CourseDetail {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final String duration;
  final bool isPremium;
  final double price;
  final String description;
  final String icon;
  final String deliveryMode; // Online, Offline, Hybrid
  final List<CourseModule> modules;
  bool isEnrolled;
  double progress; // 0.0 to 1.0
  bool isCompleted;
  String? certificateReference;

  CourseDetail({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.duration,
    required this.isPremium,
    required this.price,
    required this.description,
    required this.icon,
    this.deliveryMode = 'Online',
    required this.modules,
    this.isEnrolled = false,
    this.progress = 0.0,
    this.isCompleted = false,
    this.certificateReference,
  });

  int get totalLessons => modules.fold(0, (sum, m) => sum + m.lessons.length);
  int get completedLessons => modules.fold(0, (sum, m) => sum + m.lessons.where((l) => l.isCompleted).length);

  void updateProgress() {
    if (totalLessons > 0) {
      progress = completedLessons / totalLessons;
      if (progress >= 1.0) {
        isCompleted = true;
        certificateReference = 'CERT-ECO-${id.toUpperCase()}-${DateTime.now().year}';
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isEnrolled': isEnrolled,
        'progress': progress,
        'isCompleted': isCompleted,
        'certificateReference': certificateReference,
        'modules': modules.map((m) => m.toJson()).toList(),
      };
}

final List<CourseDetail> kDetailedCourses = [
  CourseDetail(
    id: 'c1',
    title: 'Product Photography for Rural Products',
    instructor: 'Ananya Sharma',
    category: 'Marketing',
    duration: '2h 30m',
    isPremium: false,
    price: 0,
    description: 'Learn how to take professional, high-converting product photographs using just your smartphone. Master lighting, angles, and background styling.',
    icon: '📸',
    deliveryMode: 'Online & Offline Downloadable',
    modules: [
      CourseModule(title: 'Module 1: Smartphone Lighting & Angles', lessons: [
        CourseLesson(id: 'l1', title: 'Natural Lighting Setup', duration: '12m', videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4', contentSummary: 'Use diffused window light and avoid direct flash.'),
        CourseLesson(id: 'l2', title: 'Flat Lay vs 45-Degree Angles', duration: '15m', videoUrl: '', contentSummary: 'Choosing the correct angle for GI handicrafts and food items.'),
      ]),
      CourseModule(title: 'Module 2: Backgrounds & Editing', lessons: [
        CourseLesson(id: 'l3', title: 'Creating Clean Backgrounds', duration: '18m', videoUrl: '', contentSummary: 'Using chart papers and natural textures.'),
        CourseLesson(id: 'l4', title: 'Basic Contrast & Brightness Adjustment', duration: '20m', videoUrl: '', contentSummary: 'Enhancing appeal without misrepresenting product colors.'),
      ]),
    ],
  ),
  CourseDetail(
    id: 'c2',
    title: 'Organic Farming Certification Process',
    instructor: 'ICAR Institute',
    category: 'Farming',
    duration: '3h 15m',
    isPremium: false,
    price: 0,
    description: 'Step-by-step guidance on obtaining NPOP and PGS-India organic certification for agricultural produce, handling soil audits, and maintaining farm diaries.',
    icon: '🌱',
    deliveryMode: 'Hybrid (Online Theory + Regional Hub Practical Workshop)',
    modules: [
      CourseModule(title: 'Module 1: NPOP & PGS Standards', lessons: [
        CourseLesson(id: 'l5', title: 'Introduction to Organic Standards', duration: '25m', videoUrl: '', contentSummary: 'Understanding conversion period and prohibited inputs.'),
        CourseLesson(id: 'l6', title: 'Maintaining Farm Diary Records', duration: '20m', videoUrl: '', contentSummary: 'Recording sowing dates, organic manure application, and harvest logs.'),
      ]),
      CourseModule(title: 'Module 2: Audit & Inspection', lessons: [
        CourseLesson(id: 'l7', title: 'Preparing for Third-Party Inspection', duration: '30m', videoUrl: '', contentSummary: 'Buffer zones, isolation distances, and storage segregation.'),
      ]),
    ],
  ),
  CourseDetail(
    id: 'c3',
    title: 'Digital Payments & Banking Basics',
    instructor: 'RBI Edu Team',
    category: 'Financial',
    duration: '1h 45m',
    isPremium: false,
    price: 0,
    description: 'Learn secure UPI transactions, EcoBharat Pay rural escrow wallets, DBT subsidy tracking, and protection against financial fraud.',
    icon: '💰',
    deliveryMode: 'Online',
    modules: [
      CourseModule(title: 'Module 1: UPI & Mobile Banking', lessons: [
        CourseLesson(id: 'l8', title: 'Setting up UPI Securely', duration: '15m', videoUrl: '', contentSummary: 'PIN hygiene, never sharing credentials, and verifying VPA.'),
        CourseLesson(id: 'l9', title: 'EcoBharat Pay Escrow Payouts', duration: '20m', videoUrl: '', contentSummary: 'Receiving direct payments for rural produce securely.'),
      ]),
    ],
  ),
  CourseDetail(
    id: 'c4',
    title: 'Handicraft Quality Standards & Finishing',
    instructor: 'Master Artisan Kailash',
    category: 'Artisan',
    duration: '4h',
    isPremium: true,
    price: 499,
    description: 'Advanced finishing techniques, GI compliance, durable packaging, and quality grading for export-grade Indian handicrafts.',
    icon: '🎨',
    deliveryMode: 'Hybrid (Masterclass Videos + Artisan Workshop Demo)',
    modules: [
      CourseModule(title: 'Module 1: Surface Treatment & Finishing', lessons: [
        CourseLesson(id: 'l10', title: 'Traditional Polishing Methods', duration: '35m', videoUrl: '', contentSummary: 'Eco-friendly wood and metal finishes.'),
        CourseLesson(id: 'l11', title: 'Quality Inspection Checklists', duration: '25m', videoUrl: '', contentSummary: 'Defect identification and grading standards.'),
      ]),
    ],
  ),
  CourseDetail(
    id: 'c5',
    title: 'Export Documentation & Procedures',
    instructor: 'DGFT Expert',
    category: 'Trade',
    duration: '2h',
    isPremium: true,
    price: 999,
    description: 'Complete guide to IEC code registration, customs clearance, phytosanitary certificates, and global marketplace selling.',
    icon: '🌍',
    deliveryMode: 'Online',
    modules: [
      CourseModule(title: 'Module 1: IEC & Customs Basics', lessons: [
        CourseLesson(id: 'l12', title: 'Obtaining Import-Export Code (IEC)', duration: '30m', videoUrl: '', contentSummary: 'DGFT portal registration walkthrough.'),
        CourseLesson(id: 'l13', title: 'Phytosanitary & Certificate of Origin', duration: '25m', videoUrl: '', contentSummary: 'Navigating agricultural export requirements.'),
      ]),
    ],
  ),
  CourseDetail(
    id: 'c6',
    title: 'Sustainable Packaging & Eco Practices',
    instructor: 'GreenPack Collective',
    category: 'Sustainability',
    duration: '1h 30m',
    isPremium: false,
    price: 0,
    description: 'Replacing single-use plastics with compostable kraft boxes, natural jute fillers, and biodegradable paper tape.',
    icon: '♻️',
    deliveryMode: 'Online',
    modules: [
      CourseModule(title: 'Module 1: Eco-Friendly Packaging Materials', lessons: [
        CourseLesson(id: 'l14', title: 'Compostable Materials Overview', duration: '20m', videoUrl: '', contentSummary: 'Plant-based films and molded fiber trays.'),
        CourseLesson(id: 'l15', title: 'Moisture Barrier Sealing without Plastic', duration: '25m', videoUrl: '', contentSummary: 'Wax-coated kraft paper and silica gel packs.'),
      ]),
    ],
  ),
];

class LearningNotifier extends StateNotifier<List<CourseDetail>> {
  LearningNotifier() : super(kDetailedCourses) {
    _loadProgress();
  }

  static const String _storageKey = 'ecosus_learning_progress_v1';

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        for (final course in state) {
          if (decoded.containsKey(course.id)) {
            final data = decoded[course.id];
            course.isEnrolled = data['isEnrolled'] ?? false;
            course.progress = (data['progress'] as num?)?.toDouble() ?? 0.0;
            course.isCompleted = data['isCompleted'] ?? false;
            course.certificateReference = data['certificateReference'];
            if (data['modules'] is List) {
              final modList = data['modules'] as List;
              for (int i = 0; i < course.modules.length && i < modList.length; i++) {
                final savedMod = modList[i];
                if (savedMod['lessons'] is List) {
                  final lessonList = savedMod['lessons'] as List;
                  for (int j = 0; j < course.modules[i].lessons.length && j < lessonList.length; j++) {
                    course.modules[i].lessons[j].isCompleted = lessonList[j]['isCompleted'] ?? false;
                  }
                }
              }
            }
          }
        }
        state = [...state];
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = <String, dynamic>{};
      for (final c in state) {
        map[c.id] = c.toJson();
      }
      await prefs.setString(_storageKey, jsonEncode(map));
    } catch (_) {}
  }

  Future<void> enroll(String courseId) async {
    final index = state.indexWhere((c) => c.id == courseId);
    if (index >= 0) {
      state[index].isEnrolled = true;
      state = [...state];
      await _persist();
    }
  }

  Future<void> toggleLesson(String courseId, String lessonId) async {
    final course = state.firstWhere((c) => c.id == courseId);
    for (final m in course.modules) {
      for (final l in m.lessons) {
        if (l.id == lessonId) {
          l.isCompleted = !l.isCompleted;
        }
      }
    }
    course.updateProgress();
    state = [...state];
    await _persist();
  }
}

final learningProvider = StateNotifierProvider<LearningNotifier, List<CourseDetail>>((ref) {
  return LearningNotifier();
});

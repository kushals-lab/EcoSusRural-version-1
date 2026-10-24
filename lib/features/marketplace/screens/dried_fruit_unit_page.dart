/// 5.1 Dried fruit unit page: course videos + 9:1 planner + lab workflow.
library dried_fruit_unit_page;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/processing_models.dart';
import 'hub_detail_widgets.dart';

const List<HubLesson> kDriedFruitLessons = [
  HubLesson(
    id: 'df1',
    title: 'Solar dehydration unit setup (farm shed)',
    duration: '18 min',
    instructor: 'CFTRI Field Team',
    summary:
        'Build a low-cost solar tunnel dryer: tray spacing, airflow, night covering and monsoon backup. Includes material list under Rs 25,000.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=solar+tunnel+dryer+fruit+dehydration+setup',
    isPremium: false,
  ),
  HubLesson(
    id: 'df2',
    title: 'Vacuum drying + moisture sealing',
    duration: '22 min',
    instructor: 'Food Process Engineer',
    summary:
        'When to shift from solar to vacuum drying for mango, banana and apple. Moisture targets (12–15%), seal testing and pouch selection.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=vacuum+drying+mango+moisture+sealing',
    isPremium: true,
  ),
  HubLesson(
    id: 'df3',
    title: 'FSSAI / FDA / EFSA licensing path',
    duration: '15 min',
    instructor: 'Export Compliance Desk',
    summary:
        'Step-by-step FSSAI central licence, US-FDA facility registration and EU buyer specs for dried fruits. Document checklist included.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=FSSAI+FDA+EFSA+food+export+license+India',
    isPremium: true,
  ),
];

const List<LabReportRequirement> kDriedFruitLabReports = [
  LabReportRequirement(
      name: 'FSSAI food-safety test', why: 'Microbiology + shelf-life validity.'),
  LabReportRequirement(
      name: 'Moisture & water-activity report',
      why: 'Proves 12–15% drying for export transit.'),
  LabReportRequirement(
      name: 'Pesticide residue screen',
      why: 'Required by EU/US/Middle-East buyers.'),
];

class DriedFruitUnitPage extends StatelessWidget {
  const DriedFruitUnitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Setup Dried Fruit Unit',
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: kHubGreen)),
        centerTitle: true,
      ),
      body: SafeArea(child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          const OrganicTagNotice(),
          SizedBox(height: 14.h),
          const DryYieldCalculator(),
          SizedBox(height: 14.h),
          const HubCourseVideos(lessons: kDriedFruitLessons),
          const HubYoutubeCourses(courses: kDriedFruitYoutubeCourses),
          const LabReportChecklist(requirements: kDriedFruitLabReports),
          SizedBox(height: 20.h),
        ],
      )),
    );
  }
}

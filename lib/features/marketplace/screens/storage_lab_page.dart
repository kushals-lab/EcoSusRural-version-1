/// 5.2 Storage + labs page: booking form + course videos + lab workflow.
library storage_lab_page;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/processing_models.dart';
import 'hub_detail_widgets.dart';
import 'hub_storage_form.dart';

const List<HubLesson> kStorageLabLessons = [
  HubLesson(
    id: 'sl1',
    title: 'Choosing cold storage vs dry warehouse',
    duration: '14 min',
    instructor: 'Agri-Logistics Desk',
    summary:
        'Onion, tomato and garlic need different regimes. Learn temperature bands, stacking and warehouse-receipt financing basics.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=cold+storage+vs+dry+warehouse+onion+tomato+garlic',
    isPremium: false,
  ),
  HubLesson(
    id: 'sl2',
    title: 'Shelf-life validation + lab sampling',
    duration: '16 min',
    instructor: 'Accredited Lab Partner',
    summary:
        'How to draw a lab sample, which microbiology panels to order and how to read the shelf-life certificate.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=shelf+life+validation+lab+sampling+food',
    isPremium: true,
  ),
];

const List<LabReportRequirement> kStorageLabReports = [
  LabReportRequirement(
      name: 'Microbiology + shelf-life certificate',
      why: 'Needed for storage beyond 30 days.'),
  LabReportRequirement(
      name: 'Warehouse quality assay',
      why: 'Moisture, infestation and grading proof.'),
];

class StorageLabPage extends StatelessWidget {
  const StorageLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Connect with Storage & Labs',
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
          const StorageLabForm(),
          SizedBox(height: 14.h),
          const HubCourseVideos(lessons: kStorageLabLessons),
          const HubYoutubeCourses(courses: kStorageYoutubeCourses),
          const LabReportChecklist(requirements: kStorageLabReports),
          SizedBox(height: 20.h),
        ],
      )),
    );
  }
}

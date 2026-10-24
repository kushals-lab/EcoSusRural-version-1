/// 5.3 Spice lab page: course videos + spice/nut ratios + lab workflow.
library spice_lab_page;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/processing_models.dart';
import 'hub_detail_widgets.dart';

const List<HubLesson> kSpiceLabLessons = [
  HubLesson(
    id: 'sp1',
    title: 'Curing + aroma retention (turmeric, chilli)',
    duration: '19 min',
    instructor: 'Spice Board Trainer',
    summary:
        'Boiling, polishing and solar curing windows that lock curcumin and capsaicin. Grading demo included.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=turmeric+chilli+curing+aroma+retention+processing',
    isPremium: false,
  ),
  HubLesson(
    id: 'sp2',
    title: 'Nuts & fox-nuts: grading + drying',
    duration: '17 min',
    instructor: 'Nuts Processing Unit',
    summary:
        'Walnut, almond, cashew and makhana ratios: shelling loss, roasting curves and export-grade sorting.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=walnut+almond+cashew+makhana+grading+drying+processing',
    isPremium: true,
  ),
  HubLesson(
    id: 'sp3',
    title: 'Spice Board CRES + lab paperwork',
    duration: '13 min',
    instructor: 'Export Compliance Desk',
    summary:
        'CRES registration flow, adulteration panels and how to attach lab PDFs to every export lot.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=spice+board+CRES+registration+export+lab+report',
    isPremium: true,
  ),
];

const List<LabReportRequirement> kSpiceLabReports = [
  LabReportRequirement(
      name: 'Pesticide residue (NABL) report',
      why: 'EU/US entry requirement for spices.'),
  LabReportRequirement(
      name: 'Aflatoxin + adulteration panel',
      why: 'Chilli, turmeric and nut safety proof.'),
  LabReportRequirement(
      name: 'Spice Board quality certificate',
      why: 'Needed for CRES-linked exports.'),
];

class SpiceLabPage extends StatelessWidget {
  const SpiceLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Upload Spice Lab Report',
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
          const HubCourseVideos(lessons: kSpiceLabLessons),
          const HubYoutubeCourses(courses: kSpiceYoutubeCourses),
          const LabReportChecklist(requirements: kSpiceLabReports),
          SizedBox(height: 20.h),
        ],
      )),
    );
  }
}

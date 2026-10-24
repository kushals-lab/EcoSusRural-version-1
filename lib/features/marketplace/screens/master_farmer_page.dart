/// 5.5 Master Farmer Faculty page: faculty form + course videos.
library master_farmer_page;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/processing_models.dart';
import 'hub_detail_widgets.dart';

const List<HubLesson> kMasterFarmerLessons = [
  HubLesson(
    id: 'mf1',
    title: 'Record your first farm lesson (phone only)',
    duration: '12 min',
    instructor: 'Media Coach',
    summary:
        'Framing, voice-over in your dialect and uploading a lesson that plays offline in low-connectivity villages.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=record+farm+video+lesson+smartphone+tutorial',
    isPremium: false,
  ),
  HubLesson(
    id: 'mf2',
    title: 'Off-season income: processing + repair trades',
    duration: '20 min',
    instructor: 'Skill Mission Trainer',
    summary:
        'Food processing, solar-pump repair, handicraft carving and packaging — 3–4 month earning plans.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=off+season+income+farmers+food+processing+skill',
    isPremium: false,
  ),
  HubLesson(
    id: 'mf3',
    title: 'Host paid on-farm apprenticeships',
    duration: '15 min',
    instructor: 'Master Farmer Panel',
    summary:
        'Batch sizing, safety, fee slabs and mentoring youth who then join your unit.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=on+farm+apprenticeship+program+faculty+training',
    isPremium: true,
  ),
];

class MasterFarmerPage extends StatefulWidget {
  const MasterFarmerPage({super.key});

  @override
  State<MasterFarmerPage> createState() => _MasterFarmerPageState();
}

class _MasterFarmerPageState extends State<MasterFarmerPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _skillCtrl =
      TextEditingController(text: 'Solar mango drying');
  String _mode = 'Online + Offline';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Join Master Farmer Faculty',
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: kHubGreen)),
        centerTitle: true,
      ),
      body: SafeArea(child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Text('Faculty application',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900)),
          SizedBox(height: 8.h),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Your name + village',
                border: OutlineInputBorder()),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _skillCtrl,
            decoration: const InputDecoration(
                labelText: 'Skill you will teach',
                border: OutlineInputBorder()),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
                  isExpanded: true,
                  itemHeight: null,
            initialValue: _mode,
            decoration: const InputDecoration(
                labelText: 'Teaching mode',
                border: OutlineInputBorder()),
            items: const ['Online + Offline', 'Online only', 'Offline only']
                .map((t) =>
                    DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _mode = v ?? _mode),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kHubGreen,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Faculty application saved for ${_nameCtrl.text.trim().isEmpty ? 'you' : _nameCtrl.text.trim()} ($_mode). Panel will review.')),
                );
              },
              icon:
                  const Icon(Icons.school_outlined, color: Colors.white),
              label: const Text('Apply to faculty',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(height: 14.h),
          const HubCourseVideos(lessons: kMasterFarmerLessons),
          const HubYoutubeCourses(courses: kMasterFarmerYoutubeCourses),
          SizedBox(height: 20.h),
        ],
      )),
    );
  }
}

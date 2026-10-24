/// 5.4 Organic input plant page: registration form + course videos + lab flow.
library organic_input_page;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/processing_models.dart';
import 'hub_detail_widgets.dart';

const List<HubLesson> kOrganicInputLessons = [
  HubLesson(
    id: 'oi1',
    title: 'Vermicompost + bio-fertilizer plant layout',
    duration: '21 min',
    instructor: 'ICAR Bio-Input Cell',
    summary:
        'Shed sizing, windrow beds, culture sourcing and batch records that pass state inspections.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=vermicompost+biofertilizer+plant+setup+layout',
    isPremium: false,
  ),
  HubLesson(
    id: 'oi2',
    title: 'Neem biopesticide + pheromone traps',
    duration: '16 min',
    instructor: 'Central Insecticides Board Guide',
    summary:
        'Formulation limits, labelling rules and dealer-network setup for your block.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=neem+biopesticide+pheromone+trap+manufacturing',
    isPremium: true,
  ),
];

const List<LabReportRequirement> kOrganicInputLabReports = [
  LabReportRequirement(
      name: 'Input quality assay (NPK / CFU)',
      why: 'Proves compost / bio-fertilizer strength.'),
  LabReportRequirement(
      name: 'Heavy-metal + pathogen screen',
      why: 'Mandatory before Organic Tag + marketplace sale.'),
];

class OrganicInputPage extends StatefulWidget {
  const OrganicInputPage({super.key});

  @override
  State<OrganicInputPage> createState() => _OrganicInputPageState();
}

class _OrganicInputPageState extends State<OrganicInputPage> {
  final TextEditingController _plantCtrl =
      TextEditingController(text: 'Shree Vermicompost Unit');
  final TextEditingController _capacityCtrl =
      TextEditingController(text: '500');
  String _inputType = 'Vermicompost';

  @override
  void dispose() {
    _plantCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Register Organic Input Plant',
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
          Text('Plant registration',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900)),
          SizedBox(height: 8.h),
          TextField(
            controller: _plantCtrl,
            decoration: const InputDecoration(
                labelText: 'Plant / unit name',
                border: OutlineInputBorder()),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  itemHeight: null,
                  initialValue: _inputType,
                  decoration: const InputDecoration(
                      labelText: 'Input type',
                      border: OutlineInputBorder()),
                  items: const [
                    'Vermicompost',
                    'Neem biopesticide',
                    'Bio-fertilizer',
                    'Pheromone traps',
                    'Ayurvedic cosmetic base'
                  ]
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _inputType = v ?? _inputType),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: _capacityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Capacity/month (kg)',
                      border: OutlineInputBorder()),
                ),
              ),
            ],
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
                          '$_inputType plant "${_plantCtrl.text.trim()}" registered for ${_capacityCtrl.text.trim()} kg/month. Upload lab reports below.')),
                );
              },
              icon: const Icon(Icons.factory_outlined, color: Colors.white),
              label: const Text('Register plant',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(height: 14.h),
          const HubCourseVideos(lessons: kOrganicInputLessons),
          const HubYoutubeCourses(courses: kOrganicYoutubeCourses),
          const LabReportChecklist(
              requirements: kOrganicInputLabReports),
          SizedBox(height: 20.h),
        ],
      )),
    );
  }
}

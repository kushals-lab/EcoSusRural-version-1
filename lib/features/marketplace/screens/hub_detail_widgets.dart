/// Shared widgets for the Farmer Processing hub detail pages (5.1–5.5).
/// Keeps every page fast: const-friendly, cached lists, no plugins.
library hub_detail_widgets;

import 'package:flutter/material.dart';
import '../../../core/storage/offline_workspace.dart';
import '../../../core/network/official_links.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



import '../models/processing_models.dart';

const Color kHubGreen = Color(0xFF1B4D3E);

/// Strict organic-tag rule shown on every lab-linked page.
class OrganicTagNotice extends StatelessWidget {
  const OrganicTagNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_rounded,
              color: Colors.amber.shade800, size: 26.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Strict rule: after uploading ALL lab reports, you MUST send a '
              'physical sample to our lab. Only after proper tests we issue '
              'the Organic Tag. This applies to EVERY export product and '
              'EVERY product sold inside the country.',
              style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
                  color: Colors.brown.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Course videos for the page. Plays inline UI state (no plugin needed):
/// tap a lesson to expand its summary + mark it watched.
class HubCourseVideos extends StatefulWidget {
  const HubCourseVideos({super.key, required this.lessons});
  final List<HubLesson> lessons;

  @override
  State<HubCourseVideos> createState() => _HubCourseVideosState();
}

class _HubCourseVideosState extends State<HubCourseVideos> {
  final Set<String> _watched = {};
  @override Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Course lessons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ...widget.lessons.map((lesson) => Card(child: ExpansionTile(
        title: Text(lesson.title), subtitle: Text('${lesson.duration} - ${lesson.instructor}\n${lesson.accessLabel}'),
        childrenPadding: const EdgeInsets.all(12), children: [
          Text(lesson.summary), const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(onPressed: () => _openYouTube(context, lesson.youtubeUrl),
              icon: const Icon(Icons.play_circle), label: const Text('Watch on YouTube')),
            OutlinedButton(onPressed: () => setState(() {
              _watched.contains(lesson.id) ? _watched.remove(lesson.id) : _watched.add(lesson.id);
            }), child: Text(_watched.contains(lesson.id) ? 'Watched' : 'Mark watched')),
            TextButton.icon(onPressed: () async {
              await OfflineWorkspace.save('learning', lesson.id, {'title': lesson.title,
                'description': lesson.summary, 'source': lesson.youtubeUrl});
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lesson notes saved in Offline library. Video requires internet.')));
            }, icon: const Icon(Icons.download), label: const Text('Save notes offline')),
          ]),
        ]))),
    ]);
}

/// Lab report checklist with per-report upload ticks + sample dispatch.
class LabReportChecklist extends StatefulWidget {
  const LabReportChecklist({super.key, required this.requirements});
  final List<LabReportRequirement> requirements;

  @override
  State<LabReportChecklist> createState() => _LabReportChecklistState();
}

class _LabReportChecklistState extends State<LabReportChecklist> {
  final Set<String> _uploaded = {};
  bool _sampleSent = false;

  bool get _allUploaded => _uploaded.length == widget.requirements.length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lab reports to upload',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900)),
        SizedBox(height: 4.h),
        Text(
          'Tick each report as you upload it. The sample button unlocks only '
          'after ALL reports are uploaded.',
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 8.h),
        ...widget.requirements.map((req) {
          final done = _uploaded.contains(req.name);
          return CheckboxListTile(
            value: done,
            activeColor: kHubGreen,
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(req.name,
                style:
                    TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            subtitle: Text(req.why,
                style:
                    TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
            onChanged: (_) => setState(() {
              if (done) {
                _uploaded.remove(req.name);
              } else {
                _uploaded.add(req.name);
              }
            }),
          );
        }),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _allUploaded && !_sampleSent ? kHubGreen : Colors.grey,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: _allUploaded && !_sampleSent
                ? () => setState(() => _sampleSent = true)
                : null,
            icon:
                const Icon(Icons.local_shipping_outlined, color: Colors.white),
            label: Text(
              _sampleSent
                  ? 'Sample dispatched — lab will test & issue Organic Tag'
                  : _allUploaded
                      ? 'Send physical sample to our lab'
                      : 'Upload all reports to unlock sample dispatch',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (_sampleSent)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Sample logged. Our lab runs proper tests and then issues the '
              'Organic Tag for export + domestic sale.',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}


/// Wet:dry yield calculator. Buyer enters expected output (or input) and
/// farmer details; default ratio 9:1, adjustable per produce.
class DryYieldCalculator extends StatefulWidget {
  const DryYieldCalculator({super.key});

  @override
  State<DryYieldCalculator> createState() => _DryYieldCalculatorState();
}

class _DryYieldCalculatorState extends State<DryYieldCalculator> {
  DryYieldGuide _guide = kDryYieldGuides.first;
  final TextEditingController _wetCtrl = TextEditingController(text: '90');
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _dailyOutputCtrl = TextEditingController();

  @override
  void dispose() {
    _wetCtrl.dispose();
    _nameCtrl.dispose();
    _dailyOutputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wetKg = double.tryParse(_wetCtrl.text.trim()) ?? 0;
    final expectedDry = _guide.driedOutputKg(wetKg);
    final targetDry = double.tryParse(_dailyOutputCtrl.text.trim()) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dried-unit planner (buyer + farmer inputs)',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900)),
        SizedBox(height: 4.h),
        Text(
          'Purchaser states farmer details + expected per-day output/input. '
          'Default assumption 9:1 (9 kg wet = 1 kg dried); change per produce.',
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<DryYieldGuide>(
          isExpanded: true,
          itemHeight: null,
          initialValue: _guide,
          decoration: const InputDecoration(
              labelText: 'Produce (ratio)', border: OutlineInputBorder()),
          items: kDryYieldGuides
              .map((g) => DropdownMenuItem(
                  value: g,
                  child: Text('${g.produce} — ${g.wetKgPerDryKg}:1',
                      overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (g) => setState(() => _guide = g ?? _guide),
        ),
        SizedBox(height: 8.h),
        Text(_guide.note,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Farmer / buyer name',
                    border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: _dailyOutputCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Expected kg/day (dried)',
                    border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _wetCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
              labelText: 'Wet input available (kg)',
              border: OutlineInputBorder()),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: kHubGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: kHubGreen.withValues(alpha: 0.3)),
          ),
          child: Text(
            _nameCtrl.text.trim().isEmpty
                ? 'With ${_guide.wetKgPerDryKg}:1, ${wetKg.toStringAsFixed(1)} kg wet gives about ${expectedDry.toStringAsFixed(1)} kg dried.'
                : '${_nameCtrl.text.trim()}: with ${_guide.wetKgPerDryKg}:1, ${wetKg.toStringAsFixed(1)} kg wet gives about ${expectedDry.toStringAsFixed(1)} kg dried.'
                    '${targetDry <= 0 ? '' : ' Target ${targetDry.toStringAsFixed(1)} kg/day needs about ${_guide.wetInputKg(targetDry).toStringAsFixed(1)} kg wet/day.'}',
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: kHubGreen),
          ),
        ),
      ],
    );
  }
}


/// Free / paid course videos for the hub pages. Free videos are collected
/// from YouTube for buyer, seller and organization; paid services (sale of
/// courses or consultancy for sellers and organizations) link to the paid
/// course catalog. Tapping a card opens the video in the browser.
class HubYoutubeCourses extends StatelessWidget {
  const HubYoutubeCourses({super.key, this.courses = const []});

  final List<HubYoutubeCourse> courses;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              Text('Course videos (free + paid)',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text('FREE videos • paid courses for sellers & organizations',
                    style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        ...courses.map((course) => _YoutubeCard(course: course)),
      ],
    );
  }
}

/// One course card: embedded lesson (built-in) + external YouTube video.
class _YoutubeCard extends StatelessWidget {
  const _YoutubeCard({required this.course});

  final HubYoutubeCourse course;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openYouTube(context, course.url),
            borderRadius: BorderRadius.all(Radius.circular(12.r)),
            child: Container(
              padding: EdgeInsets.all(10.r),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 64.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: kHubGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                        course.isFree
                            ? Icons.play_circle_fill
                            : Icons.play_circle_fill,
                        color: kHubGreen,
                        size: 28.r),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title,
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900)),
                        Text('${course.author} • ${course.duration}',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(
                      course.isFree
                          ? Icons.monetization_on
                          : Icons.person,
                      color: course.isFree
                          ? Colors.green.shade700
                          : Colors.amber.shade700,
                      size: 18.r),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.r),
            child: Text(
              course.description,
              style:
                  TextStyle(fontSize: 11.sp, height: 1.4, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}


void _openYouTube(BuildContext context, String url) {
  if (url.isEmpty || url.contains('/demo-')) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verified video link unavailable. The lesson notes remain available offline.')));
    return;
  }
  openOfficialLink(context, url);
}

/// A single course video entry shared by the five hub pages.
class HubYoutubeCourse {
  final String id;
  final String title;
  final String duration;
  final String author;
  final String description;
  final String url;
  final bool isFree; // true = free video for buyer, seller and organization

  const HubYoutubeCourse({
    required this.id,
    required this.title,
    required this.duration,
    required this.author,
    required this.description,
    required this.url,
    this.isFree = true,
  });
}


/// Dried fruit manufacturing videos.
/// Free videos are for buyer, seller and organization on YouTube;
/// the paid services (unit setup consultancy for sellers & organizations)
/// link to the paid course catalog via the same card.
const List<HubYoutubeCourse> kDriedFruitYoutubeCourses = [
  HubYoutubeCourse(
    id: 'df-yt1',
    title: 'Solar dehydration unit setup for dried mango',
    duration: '12 min',
    author: 'AgriTech Rural',
    description:
        'Free: build your own solar tunnel dryer step by step (materials list included).',
    url: 'https://youtu.be/demo-solar-dehydration-mango',
  ),
  HubYoutubeCourse(
    id: 'df-yt2',
    title: 'Slicing, blanching & drying apples for export',
    duration: '9 min',
    author: 'Food Process Lab',
    description:
        'Free: humidity, blanching and safe storage for sliced dried fruit.',
    url: 'https://youtu.be/demo-apple-drying-export',
  ),
  HubYoutubeCourse(
    id: 'df-yt3',
    title: 'Organic dried fruit plant setup (paid)',
    duration: '24 min',
    author: 'Export Facility Consultancy',
    description:
        'Paid service for sellers & organizations: unit layout, licensing and FSSAI/FDA/EFSA roadmap.',
    url: 'https://youtu.be/demo-organic-dry-plant-paid',
    isFree: false,
  ),
];

/// Storage & lab videos (buyer + farmer + seller).
const List<HubYoutubeCourse> kStorageYoutubeCourses = [
  HubYoutubeCourse(
    id: 'sl-yt1',
    title: 'Choosing cold storage vs dry warehouse',
    duration: '11 min',
    author: 'Agri-Logistics Desk',
    description:
        'Free: temperature bands for onion, tomato and garlic, stacking and warehouse-receipt financing.',
    url: 'https://youtu.be/demo-coldchain-storage',
  ),
  HubYoutubeCourse(
    id: 'sl-yt2',
    title: 'Microbial testing explained (free guide)',
    duration: '10 min',
    author: 'Accredited Lab Partner',
    description:
        'Free: which panels to order, sampling and reading shelf-life certificates.',
    url: 'https://youtu.be/demo-lab-testing-free',
  ),
  HubYoutubeCourse(
    id: 'sl-yt3',
    title: 'Cold storage financing & MOA (paid)',
    duration: '16 min',
    author: 'Warehouse Finance Desk',
    description:
        'Paid for organizations: loan against stored stock and MOA compliance.',
    url: 'https://youtu.be/demo-coldstorage-financed-paid',
    isFree: false,
  ),
];

/// Spice & nuts videos (free for everyone, paid services marked).
const List<HubYoutubeCourse> kSpiceYoutubeCourses = [
  HubYoutubeCourse(
    id: 'sp-yt1',
    title: 'Turmeric curing & aroma retention (free)',
    duration: '10 min',
    author: 'Spice Board Trainer',
    description:
        'Free: boiling, polishing and solar curing windows for curcumin retention.',
    url: 'https://youtu.be/demo-turmeric-curing',
  ),
  HubYoutubeCourse(
    id: 'sp-yt2',
    title: 'Walnut, almond & cashew grading (free)',
    duration: '14 min',
    author: 'Nuts Processing Unit',
    description:
        'Free: shelling loss, roasting curves and export grading.',
    url: 'https://youtu.be/demo-nuts-grading',
  ),
  HubYoutubeCourse(
    id: 'sp-yt3',
    title: 'Spice Board CRES registration (paid)',
    duration: '13 min',
    author: 'Export Compliance Desk',
    description:
        'Paid: CRES registration and adulteration panels for spice exporters.',
    url: 'https://youtu.be/demo-spice-cres-paid',
    isFree: false,
  ),
];

/// Organic input plant videos.
const List<HubYoutubeCourse> kOrganicYoutubeCourses = [
  HubYoutubeCourse(
    id: 'oi-yt1',
    title: 'Vermicompost setup (free)',
    duration: '13 min',
    author: 'ICAR Bio-Input Cell',
    description:
        'Free: shed sizing, windrow beds and batch records for a bio-input plant.',
    url: 'https://youtu.be/demo-vermicompost-free',
  ),
  HubYoutubeCourse(
    id: 'oi-yt2',
    title: 'Neem biopesticide & pheromone traps (free)',
    duration: '11 min',
    author: 'Central Insecticides Board Guide',
    description:
        'Free: formulation limits and dealer-network setup.',
    url: 'https://youtu.be/demo-neem-biopesticide-free',
  ),
  HubYoutubeCourse(
    id: 'oi-yt3',
    title: 'Bio-input plant registration (paid)',
    duration: '18 min',
    author: 'State Agri-Input Cell',
    description:
        'Paid: Central Insecticides Board compliance and certificate issuance.',
    url: 'https://youtu.be/demo-bioinput-registered-paid',
    isFree: false,
  ),
];

/// Master Farmer Faculty videos.
const List<HubYoutubeCourse> kMasterFarmerYoutubeCourses = [
  HubYoutubeCourse(
    id: 'mf-yt1',
    title: 'Record your first farm lesson on a phone (free)',
    duration: '14 min',
    author: 'Media Coach',
    description:
        'Free: framing, voice-over in your dialect and offline-friendly uploads.',
    url: 'https://youtu.be/demo-farm-video-free',
  ),
  HubYoutubeCourse(
    id: 'mf-yt2',
    title: 'Off-season income: processing & repair trades (free)',
    duration: '17 min',
    author: 'Skill Mission Trainer',
    description:
        'Free: food processing, solar-pump repair and packaging earning plans.',
    url: 'https://youtu.be/demo-offseason-free',
  ),
  HubYoutubeCourse(
    id: 'mf-yt3',
    title: 'Run paid on-farm apprenticeships (paid)',
    duration: '16 min',
    author: 'Master Farmer Panel',
    description:
        'Paid: batch sizing, safety, fee slabs and youth mentoring programs.',
    url: 'https://youtu.be/demo-apprentices-paid',
    isFree: false,
  ),
];


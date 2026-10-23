/// Artisan Global Export Hub — Exporter Certification Course:
/// course videos + application certificate + 20-question exam
/// (15 MCQ + 5 subjective) for becoming a global exporter.
library exporter_course_page;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/exporter_quiz.dart';
import '../models/processing_models.dart';
import 'hub_detail_widgets.dart';

const List<HubLesson> kExporterLessons = [
  HubLesson(
    id: 'ex1',
    title: 'IEC + HS codes: your export identity',
    duration: '16 min',
    instructor: 'DGFT Desk',
    summary:
        'Register your Import Export Code, classify handicrafts with HS codes and set up digital signature for DGFT filings.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=IEC+import+export+code+HS+code+DGFT+registration',
    isPremium: false,
  ),
  HubLesson(
    id: 'ex2',
    title: 'Incoterms, freight & fair pricing',
    duration: '18 min',
    instructor: 'Trade Finance Trainer',
    summary:
        'EXW vs CIF vs DDP in plain language, transit insurance, and building your margin so middlemen never eat it.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=incoterms+EXW+CIF+DDP+export+freight+pricing',
    isPremium: true,
  ),
  HubLesson(
    id: 'ex3',
    title: 'Lab reports, sample dispatch & Organic Tag',
    duration: '14 min',
    instructor: 'Accredited Lab Partner',
    summary:
        'Upload every lab report, then dispatch the physical sample — our lab tests it and only then issues the Organic Tag for export AND domestic sales.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=organic+certification+lab+report+sample+testing',
    isPremium: true,
  ),
  HubLesson(
    id: 'ex4',
    title: 'Biodegradable packaging for global buyers',
    duration: '12 min',
    instructor: 'GreenPack Collective',
    summary:
        'Honeycomb paper, jute fillers and compostable pouches — plastic-free packing that still survives 40-day ocean transit.',
    youtubeUrl:
        'https://www.youtube.com/results?search_query=biodegradable+packaging+export+compostable+pouch',
    isPremium: false,
  ),
];

class ExporterCoursePage extends StatefulWidget {
  const ExporterCoursePage({super.key});

  @override
  State<ExporterCoursePage> createState() => _ExporterCoursePageState();
}

class _ExporterCoursePageState extends State<ExporterCoursePage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final Map<String, int> _mcqAnswers = {};
  final Map<String, TextEditingController> _written = {};
  bool _submitted = false;
  String _certId = '';

  static const int _passMarks = 11; // 70% of 15 MCQ

  @override
  void initState() {
    super.initState();
    for (final q in kExporterQuiz.where((q) => q.isSubjective)) {
      _written[q.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final c in _written.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _mcqScore {
    var score = 0;
    for (final q in kExporterQuiz.where((q) => !q.isSubjective)) {
      if (_mcqAnswers[q.id] == q.correctIndex) score++;
    }
    return score;
  }

  bool get _allMcqAnswered =>
      _mcqAnswers.length == kExporterQuiz.where((q) => !q.isSubjective).length;

  bool get _allWrittenAnswered =>
      _written.values.every((c) => c.text.trim().length >= 20);

  bool get _passed =>
      _allMcqAnswered && _allWrittenAnswered && _mcqScore >= _passMarks;

  void _submit() {
    if (!_allMcqAnswered || !_allWrittenAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Answer all 15 MCQ and write at least 20 characters in each of the 5 written answers.')),
      );
      return;
    }
    setState(() {
      _submitted = true;
      if (_passed) {
        final now = DateTime.now();
        _certId =
            'ESR-EXP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 100000}';
      }
    });
  }

  void _retry() {
    setState(() {
      _submitted = false;
      _mcqAnswers.clear();
      for (final c in _written.values) {
        c.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mcq =
        kExporterQuiz.where((q) => !q.isSubjective).toList(growable: false);
    final written =
        kExporterQuiz.where((q) => q.isSubjective).toList(growable: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Global Exporter Certification',
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: kHubGreen)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: kHubGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: kHubGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Application certificate route',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: kHubGreen)),
                SizedBox(height: 4.h),
                Text(
                  'Watch the course, then clear the 20-question exam (15 MCQ + '
                  '5 written). Score 11/15 or more with all written answers '
                  'to earn your Global Exporter Certificate.',
                  style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.45,
                      color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          const HubCourseVideos(lessons: kExporterLessons),
          SizedBox(height: 14.h),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Full name (as on certificate)',
                border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          Text('Part A — 15 MCQ',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900)),
          ...mcq.map((q) => _McqCard(
                question: q,
                selected: _mcqAnswers[q.id],
                locked: _submitted,
                onSelect: (i) => setState(() => _mcqAnswers[q.id] = i),
              )),
          SizedBox(height: 16.h),
          Text('Part B — 5 written answers',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900)),
          ...written.map((q) => _WrittenCard(
                question: q,
                controller: _written[q.id]!,
                locked: _submitted,
              )),
          SizedBox(height: 16.h),
          if (!_submitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kHubGreen,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: _submit,
                icon: const Icon(Icons.grade_outlined, color: Colors.white),
                label: const Text('Submit exam',
                    style: TextStyle(color: Colors.white)),
              ),
            )
          else
            _ResultPanel(
              name: _nameCtrl.text.trim(),
              mcqScore: _mcqScore,
              passed: _passed,
              certId: _certId,
              onRetry: _retry,
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}


/// One MCQ card: option chips select an answer (no plugin, no deprecation).
class _McqCard extends StatelessWidget {
  const _McqCard({
    required this.question,
    required this.selected,
    required this.locked,
    required this.onSelect,
  });

  final ExporterQuizQuestion question;
  final int? selected;
  final bool locked;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${question.id.toUpperCase()} — ${question.question}',
              style:
                  TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              for (var i = 0; i < question.options.length; i++)
                ChoiceChip(
                  label: Text(question.options[i],
                      style: TextStyle(fontSize: 11.sp)),
                  selected: selected == i,
                  selectedColor: kHubGreen.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                      fontSize: 11.sp,
                      color: selected == i ? kHubGreen : Colors.black87,
                      fontWeight: selected == i
                          ? FontWeight.bold
                          : FontWeight.normal),
                  onSelected: locked ? null : (_) => onSelect(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One written-answer card with guidance + min-length hint.
class _WrittenCard extends StatelessWidget {
  const _WrittenCard({
    required this.question,
    required this.controller,
    required this.locked,
  });

  final ExporterQuizQuestion question;
  final TextEditingController controller;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${question.id.toUpperCase()} — ${question.question}',
              style:
                  TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('Hint: ${question.guidance}',
              style:
                  TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            enabled: !locked,
            maxLines: 3,
            onChanged: (_) => (context as Element).markNeedsBuild(),
            decoration: InputDecoration(
              hintText: 'Write at least 20 characters…',
              border: const OutlineInputBorder(),
              counterText:
                  '${controller.text.trim().length} chars (min 20)',
            ),
          ),
        ],
      ),
    );
  }
}


/// Score + certificate (or retry) after submission.
class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.name,
    required this.mcqScore,
    required this.passed,
    required this.certId,
    required this.onRetry,
  });

  final String name;
  final int mcqScore;
  final bool passed;
  final String certId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateStr =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    if (passed) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: kHubGreen, width: 2),
          boxShadow: [
            BoxShadow(
                color: kHubGreen.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.workspace_premium,
                color: Colors.amber.shade700, size: 44.r),
            SizedBox(height: 8.h),
            Text('Certificate of Completion',
                style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: kHubGreen)),
            SizedBox(height: 6.h),
            Text(
              name.isEmpty ? 'EcoSusRural Artisan' : name,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
            SizedBox(height: 6.h),
            Text(
              'has cleared the Global Exporter Certification exam\n'
              '(MCQ score $mcqScore/15 + 5 written answers)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, height: 1.45),
            ),
            SizedBox(height: 10.h),
            Text('Cert ID: $certId',
                style: TextStyle(
                    fontSize: 11.sp, color: Colors.grey.shade600)),
            Text('Issued: $dateStr — EcoSusRural Artisan Export Hub',
                style: TextStyle(
                    fontSize: 11.sp, color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        children: [
          Text(
              'MCQ score: $mcqScore/15 — not yet passed (need 11).',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800)),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Review lessons & retry exam'),
            ),
          ),
        ],
      ),
    );
  }
}


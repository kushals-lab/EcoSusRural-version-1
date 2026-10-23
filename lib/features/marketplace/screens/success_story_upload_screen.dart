import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Moderation status for a user-uploaded success story.
enum StoryModerationStatus { pending, approved, rejected }

/// Model for a user-submitted success story / interview.
class SuccessStorySubmission {
  final String id;
  final String title;
  final String personName;
  final String description;
  final String videoFileName;
  final StoryModerationStatus status;
  final DateTime submittedAt;
  final String? rejectionReason;

  const SuccessStorySubmission({
    required this.id,
    required this.title,
    required this.personName,
    required this.description,
    required this.videoFileName,
    required this.status,
    required this.submittedAt,
    this.rejectionReason,
  });

  /// Used by the Success Stories hub to move a submission through the
  /// moderation lifecycle (e.g. pending -> approved in the demo flow).
  SuccessStorySubmission copyWith({
    StoryModerationStatus? status,
    String? rejectionReason,
  }) {
    return SuccessStorySubmission(
      id: id,
      title: title,
      personName: personName,
      description: description,
      videoFileName: videoFileName,
      status: status ?? this.status,
      submittedAt: submittedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// In-memory store for demo purposes (would be backed by an API in production).
final List<SuccessStorySubmission> globalStorySubmissions = [];

/// Screen that lets any user upload a success story video / interview.
///
/// After submission the content goes into a moderation queue. The EcoSusRural
/// team reviews it and either:
///   * **Approves** it → appears in the public Success Stories section.
///   * **Rejects** it → submitter sees the rejection reason.
///
/// This mirrors the YouTube content-moderation lifecycle.
class SuccessStoryUploadScreen extends StatefulWidget {
  const SuccessStoryUploadScreen({
    super.key,
    this.embedded = false,
    this.onSubmitted,
  });

  /// When true the screen renders without its own [AppBar] so it can be used as
  /// the "Upload Video" section inside `SuccessStoriesHubScreen`.
  final bool embedded;

  /// Fired after a submission enters the moderation queue so the host page can
  /// refresh the public stories feed.
  final ValueChanged<SuccessStorySubmission>? onSubmitted;

  @override
  State<SuccessStoryUploadScreen> createState() => _SuccessStoryUploadScreenState();
}

class _SuccessStoryUploadScreenState extends State<SuccessStoryUploadScreen>
    with AutomaticKeepAliveClientMixin<SuccessStoryUploadScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  /// Keeps an in-progress upload form alive while the user switches between the
  /// "Stories & Videos" and "Upload Video" sections of the hub.
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _personNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _simulatedFileName;
  bool _termsAccepted = false;
  bool _isSubmitting = false;

  final List<SuccessStorySubmission> _mySubmissions = [];

  @override
  void initState() {
    super.initState();
    _mySubmissions.addAll(globalStorySubmissions);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _personNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _simulateFilePick() {
    setState(() => _simulatedFileName = 'interview_video_${DateTime.now().millisecondsSinceEpoch}.mp4');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_simulatedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video or audio file to upload.')),
      );
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Content Policy to continue.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    final submission = SuccessStorySubmission(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      personName: _personNameController.text.trim(),
      description: _descriptionController.text.trim(),
      videoFileName: _simulatedFileName!,
      status: StoryModerationStatus.pending,
      submittedAt: DateTime.now(),
    );

    globalStorySubmissions.add(submission);
    // Let the host page (Success Stories hub) refresh its public feed.
    widget.onSubmitted?.call(submission);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _mySubmissions.add(submission);
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.upload_file, size: 36.r, color: _primaryGreen),
            ),
            SizedBox(height: 16.h),
            Text(
              'Story Submitted!',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your story is now under review by the EcoSusRural team. '
              'It will be published once approved. You will be notified about '
              'the review decision.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], height: 1.5),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '⚠️  Content that violates our Terms & Conditions will be rejected. '
                'Repeated violations may result in account suspension.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, color: Colors.amber.shade900, height: 1.4),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _titleController.clear();
              _personNameController.clear();
              _descriptionController.clear();
              setState(() {
                _simulatedFileName = null;
                _termsAccepted = false;
              });
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(StoryModerationStatus s) => switch (s) {
        StoryModerationStatus.approved => Colors.green.shade600,
        StoryModerationStatus.rejected => Colors.red.shade600,
        StoryModerationStatus.pending => Colors.orange.shade600,
      };

  String _statusLabel(StoryModerationStatus s) => switch (s) {
        StoryModerationStatus.approved => 'Approved ✓',
        StoryModerationStatus.rejected => 'Rejected',
        StoryModerationStatus.pending => 'Under Review',
      };

  IconData _statusIcon(StoryModerationStatus s) => switch (s) {
        StoryModerationStatus.approved => Icons.check_circle,
        StoryModerationStatus.rejected => Icons.cancel,
        StoryModerationStatus.pending => Icons.hourglass_top_rounded,
      };

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin.
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      // In embedded mode the hub owns the AppBar and the section tabs; the
      // standalone route keeps its own title bar.
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              title: Text(
                'Share Your Success Story',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
              ),
              centerTitle: true,
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _primaryGreen.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18.r, color: _primaryGreen),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Inspire fellow farmers and artisans! Upload a video or audio interview '
                      'of someone who succeeded through EcoSusRural. Our team will review and '
                      'publish approved stories in the Success Stories section.',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[800], height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              'Story Details',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
            ),
            SizedBox(height: 12.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(
                    controller: _titleController,
                    label: 'Story Title *',
                    hint: 'e.g. How I grew my income 10x with EcoSusRural',
                    validator: (v) => (v == null || v.trim().length < 5)
                        ? 'Please enter a meaningful title (min 5 chars)'
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  _field(
                    controller: _personNameController,
                    label: "Person's Name & Location *",
                    hint: 'e.g. Radha Devi • Madhubani, Bihar',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  _field(
                    controller: _descriptionController,
                    label: 'Brief Description *',
                    hint: 'Describe the journey and key achievements...',
                    maxLines: 4,
                    validator: (v) => (v == null || v.trim().length < 20)
                        ? 'Please write at least 20 characters'
                        : null,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              'Video / Audio File *',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            InkWell(
              onTap: _simulateFilePick,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _simulatedFileName != null ? _primaryGreen : Colors.grey.shade300,
                    width: _simulatedFileName != null ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _simulatedFileName != null ? Icons.video_file : Icons.cloud_upload_outlined,
                      size: 36.r,
                      color: _simulatedFileName != null ? _primaryGreen : Colors.grey[400],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _simulatedFileName ?? 'Tap to select a video or audio file',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _simulatedFileName != null ? _primaryGreen : Colors.grey[500],
                        fontWeight: _simulatedFileName != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (_simulatedFileName == null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'MP4, MOV, AVI, MP3 (max 500 MB)',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Policy',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '• Only real stories of people who have genuinely used EcoSusRural.\n'
                    '• No misleading, fake, or plagiarised content.\n'
                    '• No content that is defamatory, obscene, or violates privacy.\n'
                    '• The EcoSusRural team may reject content without explanation.\n'
                    '• Repeated violations may lead to account suspension.',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[700], height: 1.5),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        activeColor: _primaryGreen,
                        onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'I accept the Content Policy and confirm this story is authentic.',
                          style: TextStyle(fontSize: 11.sp, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file, color: Colors.white, size: 20),
                label: Text(
                  _isSubmitting ? 'Uploading...' : 'Submit Story for Review',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

            if (_mySubmissions.isNotEmpty) ...[
              SizedBox(height: 28.h),
              Text(
                'My Submissions',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
              ),
              SizedBox(height: 10.h),
              ..._mySubmissions.map((s) => _submissionCard(s)),
            ],

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        hintStyle: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _submissionCard(SuccessStorySubmission s) {
    final statusColor = _statusColor(s.status);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.video_library_rounded, color: _primaryGreen, size: 18.r),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  s.title,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(s.status), size: 12.r, color: statusColor),
                    SizedBox(width: 4.w),
                    Text(
                      _statusLabel(s.status),
                      style: TextStyle(fontSize: 10.sp, color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(s.personName, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text(
            'Submitted: ${s.submittedAt.toLocal().toIso8601String().split('T')[0]}',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
          ),
          if (s.status == StoryModerationStatus.rejected && s.rejectionReason != null) ...[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Reason: ${s.rejectionReason}',
                style: TextStyle(fontSize: 11.sp, color: Colors.red.shade700),
              ),
            ),
          ],
          if (s.status == StoryModerationStatus.pending) ...[
            SizedBox(height: 6.h),
            Text(
              '🕐 Typically reviewed within 2–3 business days.',
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500], fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

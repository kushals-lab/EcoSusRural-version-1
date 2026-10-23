import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'success_story_upload_screen.dart';

/// A published video interview shown in the public "Stories & Videos" section.
class StoryVideoEntry {
  final String title;
  final String creator;
  final String description;
  final Duration duration;

  const StoryVideoEntry({
    required this.title,
    required this.creator,
    required this.description,
    required this.duration,
  });
}

/// Seed content published by the EcoSusRural team (Section 3.1.3).
const List<StoryVideoEntry> kSuccessStoryVideos = [
  StoryVideoEntry(
    title: 'Radha Devi • Madhubani Master Artist, Bihar',
    creator: 'Radha Devi',
    description:
        'Scaled monthly income from ₹4,000 to ₹65,000 through GI-verified international direct sales to US & German conscious consumers.',
    duration: Duration(minutes: 4, seconds: 12),
  ),
  StoryVideoEntry(
    title: 'Rameshwar Patel • Dried Fruit Cooperative, Ratlam',
    creator: 'Rameshwar Patel',
    description:
        'Installed community solar dehydration unit funded via PM MUDRA through EcoSusRural; now exporting dried mango & papaya to UAE.',
    duration: Duration(minutes: 6, seconds: 5),
  ),
  StoryVideoEntry(
    title: 'Gurpreet Singh • Organic Turmeric Farmer, Punjab',
    creator: 'Gurpreet Singh',
    description:
        'Direct lab-tested curcumin 5.8% certified turmeric sales with zero middleman commissions, doubling farm net profits in 1 season.',
    duration: Duration(minutes: 3, seconds: 48),
  ),
];

/// Success Stories & Interviews hub with **two sections**:
///
///  1. **Stories & Videos** — anyone can watch published interviews and
///     approved community uploads. No login is required.
///  2. **Upload Video** — anyone can upload a success story video. Uploads go
///     through the moderation lifecycle implemented in
///     [SuccessStoryUploadScreen] before appearing in section 1.
class SuccessStoriesHubScreen extends StatefulWidget {
  const SuccessStoriesHubScreen({super.key, this.initialTabIndex = 0});

  /// 0 → Stories & Videos, 1 → Upload Video.
  final int initialTabIndex;

  @override
  State<SuccessStoriesHubScreen> createState() =>
      _SuccessStoriesHubScreenState();
}

class _SuccessStoriesHubScreenState extends State<SuccessStoriesHubScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    // Refresh the feed whenever the user settles on a section so stories
    // uploaded from the second section show up in the first one.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SuccessStorySubmission> get _published => globalStorySubmissions
      .where((s) => s.status == StoryModerationStatus.approved)
      .toList();

  List<SuccessStorySubmission> get _awaitingReview => globalStorySubmissions
      .where((s) => s.status != StoryModerationStatus.approved)
      .toList();

  /// Demo shortcut: skips the manual review queue so the publish flow can be
  /// seen end-to-end. Production approval happens in the admin console.
  void _publishForDemo(SuccessStorySubmission submission) {
    final index =
        globalStorySubmissions.indexWhere((s) => s.id == submission.id);
    if (index == -1) return;
    globalStorySubmissions[index] = submission.copyWith(
      status: StoryModerationStatus.approved,
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo: story approved and published to Stories & Videos.'),
      ),
    );
  }

  void _openPlayer({
    required String title,
    required String creator,
    required String description,
    required Duration duration,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StoryPlayerSheet(
        title: title,
        creator: creator,
        description: description,
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Success Stories & Interviews',
          style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: _primaryGreen),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primaryGreen,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: _primaryGreen,
          tabs: const [
            Tab(
              icon: Icon(Icons.play_circle_outline),
              text: 'Stories & Videos',
            ),
            Tab(
              icon: Icon(Icons.cloud_upload_outlined),
              text: 'Upload Video',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStoriesSection(),
          // Anyone (buyer, farmer, artisan, visitor) can upload — no auth gate.
          SuccessStoryUploadScreen(
            embedded: true,
            onSubmitted: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    final published = _published;
    final awaiting = _awaitingReview;

    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B4D3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.video_library, color: Colors.white, size: 26),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Watch rural success, or share your own',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Anyone can watch these interviews — no login needed. Use the '
                '"Upload Video" section to add your own success story.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12.sp,
                    height: 1.5),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        _sectionTitle('Featured Video Interviews'),
        ...kSuccessStoryVideos.map(
          (video) => _watchCard(
            title: video.title,
            subtitle: video.creator,
            description: video.description,
            duration: video.duration,
            badge: 'Verified',
            badgeColor: _primaryGreen,
            onTap: () => _openPlayer(
              title: video.title,
              creator: video.creator,
              description: video.description,
              duration: video.duration,
            ),
          ),
        ),
        SizedBox(height: 18.h),
        _sectionTitle('Community Uploads'),
        if (published.isEmpty)
          _emptyNote(
            'No community videos published yet. Switch to "Upload Video" and '
            'be the first to share your story.',
          )
        else
          ...published.map(
            (s) => _watchCard(
              title: s.title,
              subtitle: s.personName,
              description: s.description,
              duration: const Duration(minutes: 3),
              badge: 'Approved',
              badgeColor: Colors.green.shade600,
              onTap: () => _openPlayer(
                title: s.title,
                creator: s.personName,
                description: s.description,
                duration: const Duration(minutes: 3),
              ),
            ),
          ),
        if (awaiting.isNotEmpty) ...[
          SizedBox(height: 18.h),
          _sectionTitle('Waiting for review'),
          ...awaiting.map(_reviewCard),
        ],
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: _primaryGreen),
      ),
    );
  }

  Widget _emptyNote(String text) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], height: 1.5),
      ),
    );
  }

  Widget _watchCard({
    required String title,
    required String subtitle,
    required String description,
    required Duration duration,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 74.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B4D3E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: const Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 28),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$subtitle · ${_formatDuration(duration)}',
                        style:
                            TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[800],
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewCard(SuccessStorySubmission s) {
    final isPending = s.status == StoryModerationStatus.pending;
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
              Icon(Icons.video_file, color: _primaryGreen, size: 18.r),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  s.title,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${s.personName} · ${s.videoFileName}',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 4.h),
          Text(
            isPending
                ? '🕐 Under review — appears in "Community Uploads" once approved.'
                : '❌ Rejected${s.rejectionReason == null ? '' : ': ${s.rejectionReason}'}',
            style: TextStyle(
              fontSize: 11.sp,
              color: isPending ? Colors.orange.shade800 : Colors.red.shade700,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryGreen,
                    side: const BorderSide(color: _primaryGreen),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: () => _openPlayer(
                    title: s.title,
                    creator: s.personName,
                    description: s.description,
                    duration: const Duration(minutes: 3),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text('Preview', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
              if (isPending) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onPressed: () => _publishForDemo(s),
                    icon: const Icon(Icons.public, size: 18),
                    label: Text('Publish (demo)',
                        style: TextStyle(fontSize: 12.sp)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Simulated full-screen video player for a success story.
///
/// Playback is simulated locally (no media package is bundled yet); when the
/// media service is wired up this widget swaps in a real video surface while
/// keeping the same chrome.
class _StoryPlayerSheet extends StatefulWidget {
  const _StoryPlayerSheet({
    required this.title,
    required this.creator,
    required this.description,
    required this.duration,
  });

  final String title;
  final String creator;
  final String description;
  final Duration duration;

  @override
  State<_StoryPlayerSheet> createState() => _StoryPlayerSheetState();
}

class _StoryPlayerSheetState extends State<_StoryPlayerSheet> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);
  static const Duration _tick = Duration(milliseconds: 250);
  static const double _step = 0.02;

  Timer? _timer;
  bool _playing = false;
  double _progress = 0; // 0.0 → 1.0

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _play() {
    if (_progress >= 1) _progress = 0;
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted) return;
      setState(() {
        _progress += _step;
        if (_progress >= 1) {
          _progress = 1;
          _playing = false;
          _timer?.cancel();
        }
      });
    });
    setState(() => _playing = true);
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _playing = false);
  }

  String get _elapsedLabel {
    final seconds = (widget.duration.inSeconds * _progress).round();
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _totalLabel {
    final m = widget.duration.inMinutes;
    final s = widget.duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF10131A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.movie_creation_outlined,
                      color: Colors.white24, size: 64),
                  IconButton(
                    iconSize: 56.r,
                    onPressed: _playing ? _pause : _play,
                    icon: Icon(
                      _playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    left: 10.w,
                    top: 10.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'SIMULATED PLAYBACK',
                        style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.white70,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: _progress.clamp(0, 1),
              activeColor: _primaryGreen,
              inactiveColor: Colors.white24,
              onChanged: (v) => setState(() => _progress = v),
            ),
            Row(
              children: [
                Text(_elapsedLabel,
                    style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
                const Spacer(),
                Text(_totalLabel,
                    style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              widget.title,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 4.h),
            Text(
              widget.creator,
              style: TextStyle(fontSize: 12.sp, color: Colors.white70),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.description,
              style:
                  TextStyle(fontSize: 12.sp, color: Colors.white70, height: 1.5),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Story added to your watch list.')),
                    );
                  },
                  icon: const Icon(Icons.favorite_border, size: 18),
                  label: const Text('Save'),
                ),
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share link copied to clipboard.')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
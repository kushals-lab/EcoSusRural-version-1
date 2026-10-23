import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'video_library_screen.dart';

/// YouTube-style long-form video player.
class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  bool _liked = false;
  bool _disliked = false;
  bool _subscribed = false;
  bool _saved = false;

  VideoItem get _video {
    for (final video in kVideoLibrary) {
      if (video.id == widget.videoId) {
        return video;
      }
    }
    return kVideoLibrary.first;
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayerWindow(video),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleBlock(video),
                      SizedBox(height: 12.h),
                      _buildStatsRow(video),
                      SizedBox(height: 14.h),
                      _buildDescription(video),
                      SizedBox(height: 14.h),
                      _buildCommentsHeader(video),
                      for (final comment in video.comments)
                        _buildComment(comment),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerWindow(VideoItem video) {
    return Container(
      height: 208.h,
      decoration: const BoxDecoration(color: Color(0xFF000000)),
      child: Stack(children: [
        Center(
          child: Container(
            width: 64.w,
            height: 64.w,
            decoration: const BoxDecoration(
              color: Color(0x55FFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 34.sp,
            ),
          ),
        ),
        Positioned(
          bottom: 8.r,
          left: 8.r,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xCC000000),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '0:00 / ${video.durationLabel} · streaming preview',
              style: TextStyle(color: Colors.white, fontSize: 10.5.sp),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTitleBlock(VideoItem video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          video.title,
          style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        Row(children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: video.thumbnailColor,
            child: Text(
              video.channel.isNotEmpty ? video.channel.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.channel,
                style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                'Verified creator',
                style: TextStyle(color: Colors.grey[400], fontSize: 10.sp),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () => setState(() => _subscribed = !_subscribed),
            style: ElevatedButton.styleFrom(
              backgroundColor: _subscribed ? const Color(0xFF333333) : const Color(0xFFFF3D3D),
            ),
            child: Text(
              _subscribed ? 'SUBSCRIBED ✓' : 'SUBSCRIBE',
              style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildStatsRow(VideoItem video) {
    return Row(
      children: [
        _statButton(
          video.viewsLabel,
          _liked,
          Icons.thumb_up,
          () {
            setState(() {
              _liked = !_liked;
              if (_liked) {
                _disliked = false;
              }
            });
          },
        ),
        SizedBox(width: 4.w),
        _statButton(
          '${_disliked ? 1 : 0}',
          _disliked,
          Icons.thumb_down,
          () {
            setState(() {
              _disliked = !_disliked;
              if (_disliked) {
                _liked = false;
              }
            });
          },
        ),
        SizedBox(width: 4.w),
        _statButton('Share', false, Icons.share, () {}),
        SizedBox(width: 4.w),
        _statButton('Save', _saved, Icons.bookmark, () {
          setState(() => _saved = !_saved);
        }),
      ],
    );
  }

  Widget _statButton(String label, bool active, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF333333) : const Color(0xFF1E1E1E),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      ),
      child: Row(children: [
        Icon(icon, size: 16.sp),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(color: active ? const Color(0xFFFFD166) : Colors.white, fontSize: 11.sp),
        ),
      ]),
    );
  }

  Widget _buildDescription(VideoItem video) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${video.viewsLabel} views · ${video.uploadedLabel}',
            style: TextStyle(color: Colors.grey[400], fontSize: 11.5.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            video.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[200], fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsHeader(VideoItem video) {
    return Row(children: [
      const Icon(Icons.mode_comment, color: Colors.white, size: 18),
      SizedBox(width: 6.w),
      Text(
        '${video.comments.length + 128} Comments',
        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
      ),
    ]);
  }

  Widget _buildComment(String comment) {
    return Container(
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: const Color(0xFF2E7D32),
            child: Text(
              comment.isNotEmpty ? comment.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(color: Colors.white, fontSize: 10.sp),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              comment,
              style: TextStyle(color: Colors.grey[200], fontSize: 11.5.sp),
            ),
          ),
          const Icon(Icons.thumb_up, color: Colors.white, size: 14),
        ],
      ),
    );
  }
}
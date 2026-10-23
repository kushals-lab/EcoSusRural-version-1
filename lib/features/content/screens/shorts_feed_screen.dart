import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Instagram / YouTube-Shorts style vertical reels feed.
class ShortsFeedScreen extends ConsumerStatefulWidget {
  const ShortsFeedScreen({super.key});

  @override
  ConsumerState<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends ConsumerState<ShortsFeedScreen> {
  int _index = 0;
  final Set<String> _liked = <String>{};
  final Set<String> _saved = <String>{};

  void _next() {
    setState(() => _index = (_index + 1) % _shorts.length);
  }

  void _previous() {
    setState(() => _index = (_index - 1 + _shorts.length) % _shorts.length);
  }

  @override
  Widget build(BuildContext context) {
    final clip = _shorts[_index];
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reels & Shorts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add_a_photo, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _clipCard(clip),
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: const Color(0xFF111111),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _previous,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF222222)),
            child: const Row(children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              Text('Previous', style: TextStyle(color: Colors.white)),
            ]),
          ),
          Text(
            '${_index + 1} / ${_shorts.length}',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF222222)),
            child: const Row(children: [
              Text('Next', style: TextStyle(color: Colors.white)),
              Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _clipCard(_Short clip) {
    final isLiked = _liked.contains(clip.id);
    final isSaved = _saved.contains(clip.id);
    return Container(
      decoration: BoxDecoration(color: clip.color1),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: _caption(clip)),
                SizedBox(height: 10.h),
                Row(children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 16),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(clip.audio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                  ),
                ]),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          // The action rail can be taller than a short card on small screens;
          // scale it down instead of overflowing the fixed-height cell.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
              _actionRail(
                clip.likes + (isLiked ? 1 : 0),
                isLiked,
                Icons.favorite,
                () {
                  setState(() {
                    if (isLiked) {
                      _liked.remove(clip.id);
                    } else {
                      _liked.add(clip.id);
                    }
                  });
                },
              ),
              _actionRail(
                clip.comments,
                false,
                Icons.mode_comment,
                () {},
              ),
              _actionRail(
                clip.shares,
                false,
                Icons.send,
                () {},
              ),
              _actionRail(
                isSaved ? 1 : 0,
                isSaved,
                Icons.bookmark,
                () {
                  setState(() {
                    if (isSaved) {
                      _saved.remove(clip.id);
                    } else {
                      _saved.add(clip.id);
                    }
                  });
                },
              ),
            ],
                  ),
                ),
              ),
        ]),
      ),
    );
  }

  Widget _caption(_Short clip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            clip.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
        ),
        SizedBox(height: 4.h),
        Row(children: [
          CircleAvatar(
            radius: 14.r,
            backgroundColor: clip.color2,
            child: Text(
              clip.creator.isNotEmpty ? clip.creator.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(color: Colors.white, fontSize: 11.sp),
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              clip.creator,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 4.w),
          if (clip.isVerified)
            const Icon(Icons.star, color: Color(0xFFFFD166), size: 14),
        ]),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 4.h,
          children: [
            for (final tag in clip.tags)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text('#$tag', style: TextStyle(color: Colors.white, fontSize: 10.5.sp)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _actionRail(int count, bool active, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(icon: Icon(icon, size: 26.sp), onPressed: onTap),
        Text(
          _shortCount(count),
          style: TextStyle(
            color: active ? const Color(0xFFFF4D6D) : Colors.white,
            fontSize: 10.5.sp,
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  static String _shortCount(int value) {
    if (value >= 1000) {
      final k = value / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    return '$value';
  }
}

class _Short {
  final String id;
  final String title;
  final String creator;
  final bool isVerified;
  final List<String> tags;
  final String audio;
  final int likes;
  final int comments;
  final int shares;
  final Color color1;
  final Color color2;

  const _Short({
    required this.id,
    required this.title,
    required this.creator,
    required this.isVerified,
    required this.tags,
    required this.audio,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.color1,
    required this.color2,
  });
}

/// Demo reel catalogue (regional, sustainability focused).
const List<_Short> _shorts = [
  _Short(
    id: 's1',
    title: 'Drip irrigation in 30 seconds — 60% less water, 2x yield 🌱',
    creator: 'Kheti Guru',
    isVerified: true,
    tags: ['agriTech', 'water', 'sustainability'],
    audio: 'Original audio · Kheti Guru',
    likes: 48200,
    comments: 1210,
    shares: 8340,
    color1: Color(0xFF1B5E20),
    color2: Color(0xFF66BB6A),
  ),
  _Short(
    id: 's2',
    title: 'Banarasi weavers of Varanasi — how one saree takes 7 days 🧵',
    creator: 'Craft & Cloth',
    isVerified: true,
    tags: ['handloom', 'GI', 'banarasi'],
    audio: 'Original audio · Craft & Cloth',
    likes: 21500,
    comments: 640,
    shares: 9200,
    color1: Color(0xFF4A148C),
    color2: Color(0xFFAB47BC),
  ),
  _Short(
    id: 's3',
    title: 'Vedic maths trick: multiply any 2-digit number in 3 seconds ✨',
    creator: 'Gurukul Live',
    isVerified: false,
    tags: ['vedicMaths', 'education', 'india'],
    audio: 'Original audio · Gurukul Live',
    likes: 96300,
    comments: 4100,
    shares: 22100,
    color1: Color(0xFFB3541E),
    color2: Color(0xFFFFB74D),
  ),
  _Short(
    id: 's4',
    title: 'Cow dung as natural pesticide 🐄 — zero-chemical farming',
    creator: 'Gram Arogya',
    isVerified: true,
    tags: ['organic', 'livestock', 'health'],
    audio: 'Original audio · Gram Arogya',
    likes: 33100,
    comments: 980,
    shares: 5210,
    color1: Color(0xFF00695C),
    color2: Color(0xFF26A69A),
  ),
  _Short(
    id: 's5',
    title: 'Meet 14-year-old Sita from Jharkhand, our youngest solar engineer ⚡',
    creator: 'Rural Spark',
    isVerified: false,
    tags: ['girlPower', 'solar', 'jobs'],
    audio: 'Original audio · Rural Spark',
    likes: 154000,
    comments: 8700,
    shares: 45200,
    color1: Color(0xFF5D4037),
    color2: Color(0xFFFFCA28),
  ),
];
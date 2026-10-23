import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'video_player_screen.dart';

/// YouTube-style long-form video library.
class VideoLibraryScreen extends StatelessWidget {
  const VideoLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EcoSusRural Videos',
          style: TextStyle(color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF1B4D3E)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications, color: Color(0xFF1B4D3E)), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryChips(),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: Text(
                '${kVideoLibrary.length} videos - curated rural knowledge',
                style: TextStyle(fontSize: 11.5.sp, color: Colors.grey[600]),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                itemCount: kVideoLibrary.length,
                itemBuilder: (context, index) {
                  final video = kVideoLibrary[index];
                  return _VideoListTile(
                    video: video,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoId: video.id)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: kVideoCategories.length,
        itemBuilder: (context, index) {
          final category = kVideoCategories[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ChoiceChip(
              selected: category == 'All',
              onSelected: (_) {},
              label: Text(category, style: TextStyle(fontSize: 12.sp)),
            ),
          );
        },
      ),
    );
  }
}

class _VideoListTile extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;

  const _VideoListTile({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170.h,
            decoration: BoxDecoration(
              color: video.thumbnailColor,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Stack(children: [
              Center(
                child: Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: const BoxDecoration(
                    color: Color(0x66FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30.sp),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: const BoxDecoration(
                    color: Color(0xCC000000),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Text(
                    video.durationLabel,
                    style: TextStyle(color: Colors.white, fontSize: 10.5.sp),
                  ),
                ),
              ),
            ]),
          ),
          SizedBox(height: 10.h),
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF212121)),
          ),
          SizedBox(height: 4.h),
          Text(
            '${video.channel} - ${video.viewsLabel} views - ${video.uploadedLabel}',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }
}
class VideoItem {
  final String id;
  final String title;
  final String channel;
  final String category;
  final String durationLabel;
  final String viewsLabel;
  final String uploadedLabel;
  final String description;
  final List<String> comments;
  final Color thumbnailColor;

  const VideoItem({
    required this.id,
    required this.title,
    required this.channel,
    required this.category,
    required this.durationLabel,
    required this.viewsLabel,
    required this.uploadedLabel,
    required this.description,
    required this.comments,
    required this.thumbnailColor,
  });
}

const List<String> kVideoCategories = [
  'All',
  'Documentaries',
  'Learning',
  'Expert Sessions',
  'Livelihood',
  'Harvest',
];

const List<VideoItem> kVideoLibrary = [
  VideoItem(
    id: 'v1',
    title: 'Zero-Budget Natural Farming - The Andhra Pradesh Model',
    channel: 'EcoSusRural Originals',
    category: 'Documentaries',
    durationLabel: '24:18',
    viewsLabel: '1.2M',
    uploadedLabel: '2 months ago',
    description: 'A deep-dive into Zero Budget Natural Farming (ZBNF): soil microbes, mulching, jeevamrut, and how 1.6 million farmers cut input costs to zero.',
    comments: ['Superb explanation of the 4-layer soil model!', 'We started ZBNF on 2 acres last season. It works!', 'Subtitles in Telugu please'],
    thumbnailColor: Color(0xFF2E7D32),
  ),
  VideoItem(
    id: 'v2',
    title: 'AI & Satellite Weather Advisory for Small Farmers',
    channel: 'Krishi AI Lab',
    category: 'Expert Sessions',
    durationLabel: '38:42',
    viewsLabel: '486K',
    uploadedLabel: '1 week ago',
    description: 'Dr. Rao demonstrates how EcoSusRural combines 5-day forecasts, soil moisture and market MSP alerts into one village-level advisory.',
    comments: ['The advisory saved my rabi crop from hailstorm!', 'Can this work offline too?', 'Very practical session.'],
    thumbnailColor: Color(0xFF0277BD),
  ),
  VideoItem(
    id: 'v3',
    title: 'Ancient Indian Gurukul Education Approach - A Modern Revival',
    channel: 'Bharat Shiksha',
    category: 'Learning',
    durationLabel: '52:07',
    viewsLabel: '890K',
    uploadedLabel: '3 weeks ago',
    description: 'Exploring the ancient education system - Vedas, memory science, ethics (vidya + vinaya), and how 21st century EdTech can rediscover it.',
    comments: ['The memory techniques are breathtaking', 'Amazing synthesis of tradition and tech', 'More episodes please!'],
    thumbnailColor: Color(0xFFC2185B),
  ),
  VideoItem(
    id: 'v4',
    title: 'Building the Banarasi Silk Cluster - Weaver Livelihoods',
    channel: 'Craft & Cloth',
    category: 'Livelihood',
    durationLabel: '18:55',
    viewsLabel: '231K',
    uploadedLabel: '5 days ago',
    description: 'How a 600-year-old handloom cluster digitized orders, got GI verification, and tripled weaver incomes through direct-to-customer commerce.',
    comments: ['Proud of our weavers', 'Bought 2 sarees through the app!', 'Please cover Kancheepuram next.'],
    thumbnailColor: Color(0xFF6A1B9A),
  ),
  VideoItem(
    id: 'v5',
    title: 'MSP Tracker Live - Understanding Minimum Support Prices 2026',
    channel: 'Market Mandi',
    category: 'Harvest',
    durationLabel: '14:32',
    viewsLabel: '156K',
    uploadedLabel: '2 days ago',
    description: 'What is MSP, how it is set, and how EcoSusRural helps you compare mandi prices against MSP in real time before you sell.',
    comments: ['Finally someone explained this clearly', 'Wheat MSP explained', 'Live mandi data is gold.'],
    thumbnailColor: Color(0xFFEF6C00),
  ),
];

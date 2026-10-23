import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'shorts_feed_screen.dart';
import 'video_library_screen.dart';

class ContentHubScreen extends StatelessWidget {
  const ContentHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentTiles = [
      _ContentTile(
        title: 'Shorts & Reels',
        subtitle: 'Creator clips, village updates, and snackable education',
        icon: Icons.play_arrow_rounded,
        color: const Color(0xFF1B4D3E),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ShortsFeedScreen()));
        },
      ),
      _ContentTile(
        title: 'Long Video',
        subtitle: 'Documentary, learning, and expert sessions',
        icon: Icons.smart_display_rounded,
        color: const Color(0xFF146C8B),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoLibraryScreen()));
        },
      ),
      _ContentTile(
        title: 'Live Commerce',
        subtitle: 'Marketplace live streams and regional product launches',
        icon: Icons.live_tv_rounded,
        color: const Color(0xFFFF8A00),
        onTap: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('EcoSusRural Video', style: TextStyle(color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Content Network', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B4D3E))),
              SizedBox(height: 8.h),
              Text('Shorts, long-form video, live education and commerce.', style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
              SizedBox(height: 16.h),
              Expanded(
                child: GridView.builder(
                  itemCount: contentTiles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: (143.w * MediaQuery.textScalerOf(context).scale(1.0)).toDouble(),
                  ),
                  itemBuilder: (context, index) => contentTiles[index],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 34.sp),
              SizedBox(height: 12.h),
              Flexible(
                child: Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color)),
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: Text(subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

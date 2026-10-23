import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Artisan Authenticity & GI Tag Registry - ACCESS RESTRICTED TO:
/// ARTISANS & CRAFTSMEN ONLY.
///
/// Header shows the craft guild identifier, region and the Geographical
/// Indication (GI) badge. Includes handcraft provenance register (QR-coded
/// certificates), GI verification portal, heritage storytelling gallery and
/// the bespoke order board.
class ArtisanGiRegistryScreen extends StatelessWidget {
  const ArtisanGiRegistryScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    const provenance = [
      ('Patan Patola Stole #A-241', 'GI IN/LOC/2013/123', 'QR issued'),
      ('Blue Pottery Urn #C-117', 'GI IN/LOC/2014/087', 'QR issued'),
      ('Bidriware Hookah Base #B-56', 'GI IN/LOC/2006/045', 'Verification due'),
    ];
    const bespoke = [
      ('Collector (Dubai) - 12 patola stoles', 'Rs 4,20,000'),
      ('Boutique (Jaipur) - 30 blue pottery sets', 'Rs 2,10,000'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('GI Tag & Craft Registry',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), _primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.handyman_outlined, color: Colors.white, size: 32.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Patan Weavers Guild - Cluster ID GJ-PTN-09',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text('Region: Patan, Gujarat', style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20.r)),
                    child: Text('GI BADGE VERIFIED',
                        style: TextStyle(color: Colors.black87, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _section('Handcraft Provenance Register', 'Unique QR-coded digital certificates of authenticity for every listed item.'),
            ...provenance.map((p) => Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(children: [
                    const Icon(Icons.qr_code_2, color: Color(0xFF6A1B9A)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.$1, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                        Text(p.$2, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                      ]),
                    ),
                    Text(p.$3, style: TextStyle(fontSize: 11.sp, color: _primaryGreen, fontWeight: FontWeight.w600)),
                  ]),
                )),
            SizedBox(height: 8.h),
            _section('GI Tag Verification Portal', 'Upload craft photos and material details to receive official artisan cluster validation.'),
            Container(
              height: 90.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF6A1B9A).withValues(alpha: 0.4), width: 1.5),
              ),
              child: Text('Upload craft photo + material details', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ),
            SizedBox(height: 12.h),
            _section('Heritage Storytelling Gallery', 'Publish videos and stories behind traditional craft techniques.'),
            Row(children: [
              _galleryCard(Icons.videocam_outlined, 'Weaving the double ikat'),
              SizedBox(width: 10.w),
              _galleryCard(Icons.photo_library_outlined, 'Natural dye process'),
            ]),
            SizedBox(height: 12.h),
            _section('Bespoke Order Board', 'Custom commission requests from premium collectors and international buyers.'),
            ...bespoke.map((b) => ListTile(
                  leading: const Icon(Icons.card_giftcard_outlined, color: Color(0xFF6A1B9A)),
                  title: Text(b.$1, style: TextStyle(fontSize: 13.sp)),
                  trailing: Text(b.$2, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                )),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 2.h),
        Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _galleryCard(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: const Color(0xFF6A1B9A)),
          SizedBox(height: 4.h),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Farmer Soil Lab & Agronomy Dashboard - ACCESS RESTRICTED TO: FARMERS ONLY.
///
/// Header shows farm location, land holding acreage and active crop cycles.
/// Soil health metric cards, AI fertilizer calculator, crop disease diagnostic
/// scanner and a seasonal agronomy schedule.
class FarmerSoilLabScreen extends StatelessWidget {
  const FarmerSoilLabScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('Soil Lab & Agronomy',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar - farm location / acreage / crop cycles.
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), _primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.grass, color: Colors.white, size: 32.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farm: Plot 14, Nashik, MH',
                            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text('Land holding: 3.5 acres  |  2 active crop cycles',
                            style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text('Soil Health Metrics',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 10.h),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: const [
                ('Nitrogen (N)', '142 kg/ha', Icons.emoji_nature_outlined, Colors.green),
                ('Phosphorus (P)', '18 kg/ha', Icons.scatter_plot_outlined, Colors.orange),
                ('Potassium (K)', '96 kg/ha', Icons.blur_circular_outlined, Colors.purple),
                ('pH Balance', '6.8', Icons.water_drop_outlined, Colors.blue),
                ('Organic Carbon', '0.62%', Icons.eco_outlined, Colors.teal),
                ('Lab Source', 'Uploaded 12 Aug', Icons.file_upload_outlined, Colors.grey),
              ]
                  .map((m) => Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(children: [
                              Icon(m.$3, color: m.$4, size: 16),
                              SizedBox(width: 6.w),
                              Flexible(
                                  child: Text(m.$1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]))),
                            ]),
                            SizedBox(height: 4.h),
                            Flexible(
                                child: Text(m.$2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14.sp, fontWeight: FontWeight.bold, color: _primaryGreen))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20.h),
            _buildFertilizerCalculator(),
            SizedBox(height: 20.h),
            _buildDiseaseScanner(),
            SizedBox(height: 20.h),
            _buildSchedule(),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  // AI fertilizer calculator.
  Widget _buildFertilizerCalculator() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFF57C00)),
            SizedBox(width: 8.w),
            Text('AI Fertilizer Calculator', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ]),
          SizedBox(height: 8.h),
          Text('Enter land area and EcoSusRural AI recommends the exact N-P-K dosage ratio to reduce input cost.',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], height: 1.4)),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Land area (acres)',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h)),
              onPressed: () {},
              child: const Text('Calculate', style: TextStyle(color: Colors.white)),
            ),
          ]),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10.r)),
            child: Text(
                'Recommended: N 45 : P 22 : K 30 kg/acre (saves approx Rs 1,850/acre vs blanket dosage)',
                style: TextStyle(fontSize: 11.sp, color: _primaryGreen, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // Crop disease diagnostic scanner.
  Widget _buildDiseaseScanner() {
    return Container(
      height: 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _primaryGreen.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, color: _primaryGreen, size: 34.r),
          SizedBox(height: 6.h),
          Text('Drop a crop leaf photograph for EcoSusRural AI diagnosis',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Seasonal agronomy schedule.
  Widget _buildSchedule() {
    const schedule = [
      ('Sowing window', '15 Jun - 05 Jul', Icons.grass_outlined, Colors.green),
      ('Irrigation interval', 'Every 9 days', Icons.water_drop_outlined, Colors.blue),
      ('Pesticide window', '22 Jul (evening)', Icons.pest_control_outlined, Colors.orange),
      ('Harvest projection', '18 Oct (+/- 4 days)', Icons.agriculture_outlined, Colors.brown),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seasonal Agronomy Schedule',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
        SizedBox(height: 6.h),
        ...schedule.map((e) => ListTile(
              leading: Icon(e.$3, color: e.$4),
              title: Text(e.$1, style: TextStyle(fontSize: 13.sp)),
              subtitle: Text(e.$2,
                  style: TextStyle(fontSize: 12.sp, color: _primaryGreen, fontWeight: FontWeight.w600)),
            )),
      ],
    );
  }
}

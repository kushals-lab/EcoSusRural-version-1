import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VillageOutreachScreen extends StatefulWidget {
  const VillageOutreachScreen({super.key});

  @override
  State<VillageOutreachScreen> createState() => _VillageOutreachScreenState();
}

class _VillageOutreachScreenState extends State<VillageOutreachScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void dispose() {
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _participantsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Village Outreach & Panchayat Portal',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Impact Dashboard
            _buildImpactDashboard(),

            SizedBox(height: 20.h),

            // Camp Booking Form
            Text('Request an Outreach Camp',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panchayats can invite EcoSusRural to organize digital literacy training, '
                    'artisan/farmer onboarding, product photography workshops, and scheme awareness sessions.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.5),
                  ),
                  SizedBox(height: 16.h),

                  TextField(
                    controller: _villageController,
                    decoration: _inputDecoration('Village Name', Icons.home),
                  ),
                  SizedBox(height: 10.h),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _districtController,
                          decoration: _inputDecoration('District', Icons.map),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: _stateController,
                          decoration: _inputDecoration('State', Icons.location_on),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  TextField(
                    controller: _participantsController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Estimated Participants', Icons.group),
                  ),
                  SizedBox(height: 10.h),

                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Contact Number', Icons.phone),
                  ),
                  SizedBox(height: 10.h),

                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: _inputDecoration('Camp Type', Icons.event),
                    items: ['Paid Camp', 'Free Annual Camp (CSR-funded)']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (_) {},
                  ),
                  SizedBox(height: 10.h),

                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: _inputDecoration('Specific Needs', Icons.checklist),
                    items: ['Artisan Onboarding', 'Farmer Scheme Awareness', 'Digital Literacy', 'Product Photography', 'Banking/UPI Setup', 'General Outreach']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (_) {},
                  ),

                  SizedBox(height: 16.h),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Camp request submitted! Our team will contact you.')),
                      );
                    },
                    child: Text('Submit Camp Request',
                        style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Camp Calendar
            Text('Upcoming Camps', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),

            _buildCampCard('Kutch, Gujarat', 'Sep 15-17, 2026', 'Artisan Onboarding + Photography', 'Ongoing'),
            _buildCampCard('Ladakh, J&K', 'Oct 5-8, 2026', 'Digital Literacy + Scheme Awareness', 'Upcoming'),
            _buildCampCard('Kohima, Nagaland', 'Nov 12-15, 2026', 'Farmer Onboarding + Weather Training', 'Upcoming'),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactDashboard() {
    final stats = [
      ('1,250+', 'Villages Reached'),
      ('85,000+', 'Artisans Onboarded'),
      ('1.2L+', 'Farmers Connected'),
      ('₹45Cr+', 'Rural Income Generated'),
    ];

    return Container(
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
          Text('Village-Level Impact',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: (99.w * MediaQuery.textScalerOf(context).scale(1.0)).toDouble(),
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(stat.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Flexible(
                      child: Text(stat.$2,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10.sp, color: Colors.white70)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCampCard(String location, String dates, String focus, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Center(child: Icon(Icons.event, color: Color(0xFF1B4D3E), size: 22)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 2.h),
                Text('$dates • $focus', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: (status == 'Ongoing' ? Colors.green : Colors.blue).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(status,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: status == 'Ongoing' ? Colors.green.shade700 : Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryGreen, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF1B4D3E), width: 2),
      ),
    );
  }
}
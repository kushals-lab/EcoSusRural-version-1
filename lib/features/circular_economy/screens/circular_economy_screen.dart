import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircularEconomyScreen extends StatefulWidget {
  const CircularEconomyScreen({super.key});

  @override
  State<CircularEconomyScreen> createState() => _CircularEconomyScreenState();
}

class _CircularEconomyScreenState extends State<CircularEconomyScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Circular Economy & Waste Management',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
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
                  Text('Waste to Wealth',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 6.h),
                  Text(
                    'EcoSusRural supports rural communities in establishing recycling facilities, '
                    'composting units, biogas plants, and waste-to-energy solutions.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Waste Separation Training
            _buildSectionCard(
              icon: Icons.recycling,
              title: 'Waste Separation Training',
              color: const Color(0xFF2E7D32),
              description: 'Community-level training programs on segregation of dry waste, wet waste, '
                  'hazardous waste, e-waste, and recyclable materials.',
            ),

            SizedBox(height: 12.h),

            // Recycling Facility Setup
            _buildSectionCard(
              icon: Icons.factory,
              title: 'Recycling Facility Setup Assistance',
              color: const Color(0xFF1565C0),
              description: 'Guidance on establishing plastic, metal, and e-waste recycling units — '
                  'collection, sorting, washing, shredding, pelletising.',
            ),

            SizedBox(height: 12.h),

            // Bio-Manure Production
            _buildSectionCard(
              icon: Icons.agriculture,
              title: 'Bio-Manure Production',
              color: const Color(0xFF558B2F),
              description: 'Establishing community-level composting facilities for organic waste → '
                  'vermicompost and organic manure production. Sold through the EcoSusRural marketplace.',
            ),

            SizedBox(height: 12.h),

            // Bio-Gas Production
            _buildSectionCard(
              icon: Icons.local_fire_department,
              title: 'Bio-Gas Production',
              color: const Color(0xFFF57C00),
              description: 'Setting up small-scale biogas plants using agricultural waste and animal dung. '
                  'Biogas for cooking fuel and electricity generation.',
            ),

            SizedBox(height: 12.h),

            // Waste-to-Energy
            _buildSectionCard(
              icon: Icons.bolt,
              title: 'Waste-to-Energy',
              color: const Color(0xFF7B1FA2),
              description: 'Information on waste-to-energy technologies appropriate for rural scale, '
                  'with supply and distribution support through the marketplace.',
            ),

            SizedBox(height: 20.h),

            // EcoSusRural's Role
            Text("EcoSusRural's Role",
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
                  _roleItem(Icons.verified_user, 'Establishing & Regulating facilities'),
                  _roleItem(Icons.description, 'Licensing assistance — most paperwork handled by EcoSusRural'),
                  _roleItem(Icons.support_agent, 'Ongoing compliance check-ins and operational support'),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Apply for Setup Assistance
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Setup assistance request submitted! Our team will contact you.')),
                );
              },
              child: Text('Apply for Setup Assistance',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 4.h),
                Text(description, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, color: _primaryGreen, size: 18),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpertModel {
  final String id;
  final String name;
  final String specialty;
  final String description;
  final String icon;
  final bool isAvailable;

  const ExpertModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.description,
    required this.icon,
    this.isAvailable = true,
  });
}

const List<ExpertModel> kExperts = [
  ExpertModel(
    id: 'exp1',
    name: 'Dr. S. Swaminathan',
    specialty: 'Agricultural Science',
    description: 'Agronomist specializing in crop planning, soil health, and sustainable farming.',
    icon: '🌾',
  ),
  ExpertModel(
    id: 'exp2',
    name: 'Kailash Verma',
    specialty: 'Craft Development',
    description: 'Master artisan and craft development officer for handicraft certification.',
    icon: '🎨',
  ),
  ExpertModel(
    id: 'exp3',
    name: 'Anita Desai',
    specialty: 'Financial Advisory',
    description: 'MSME finance expert for loans, tax planning, and accounting.',
    icon: '💰',
  ),
  ExpertModel(
    id: 'exp4',
    name: 'Rajesh Kumar',
    specialty: 'Legal Advisory',
    description: 'Legal expert for government schemes, land rights, and IP protection.',
    icon: '⚖️',
  ),
  ExpertModel(
    id: 'exp5',
    name: 'Meera Nair',
    specialty: 'Marketing & Branding',
    description: 'Marketing consultant for pricing, branding, and market entry strategies.',
    icon: '📈',
  ),
];

class ExpertAdviceScreen extends StatefulWidget {
  const ExpertAdviceScreen({super.key});

  @override
  State<ExpertAdviceScreen> createState() => _ExpertAdviceScreenState();
}

class _ExpertAdviceScreenState extends State<ExpertAdviceScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
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
          'Expert Advice Portal',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ask a Question Card
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
                  Text('Ask an Expert',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8.h),
                  Text(
                    'Submit your question to our panel of domain experts. Get answers within 24-48 hours.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Type your question here...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _primaryGreen,
                      minimumSize: Size(double.infinity, 44.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      if (_questionController.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Question submitted! An expert will respond soon.')),
                        );
                        _questionController.clear();
                      }
                    },
                    child: Text('Submit Question',
                        style: TextStyle(color: _primaryGreen, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Expert Panel
            Text('Expert Panel', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),

            ...kExperts.map(_buildExpertCard),

            SizedBox(height: 20.h),

            // Live Sessions
            Text('Scheduled Live Sessions', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.all(14.r),
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
                      const Icon(Icons.videocam, color: Colors.red, size: 20),
                      SizedBox(width: 8.w),
                      Text('Live Q&A: Organic Certification Process',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text('Friday, 6:00 PM • Dr. S. Swaminathan • Premium subscribers',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCard(ExpertModel expert) {
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
            child: Center(child: Text(expert.icon, style: TextStyle(fontSize: 22.sp))),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expert.name,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 2.h),
                Text(expert.specialty, style: TextStyle(fontSize: 12.sp, color: _primaryGreen, fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(expert.description,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (expert.isAvailable)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat with ${expert.name} coming soon.')),
                );
              },
              child: Text('Ask', style: TextStyle(color: _primaryGreen, fontSize: 12.sp)),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MspCropModel {
  final String crop;
  final double msp;
  final double mandiPrice;
  final String unit;

  const MspCropModel({
    required this.crop,
    required this.msp,
    required this.mandiPrice,
    required this.unit,
  });
}

const List<MspCropModel> kMspCrops = [
  MspCropModel(crop: 'Wheat', msp: 2275, mandiPrice: 2400, unit: 'quintal'),
  MspCropModel(crop: 'Paddy (Common)', msp: 2183, mandiPrice: 2050, unit: 'quintal'),
  MspCropModel(crop: 'Cotton', msp: 7121, mandiPrice: 6800, unit: 'quintal'),
  MspCropModel(crop: 'Sugarcane (FRP)', msp: 3400, mandiPrice: 3400, unit: 'quintal'),
  MspCropModel(crop: 'Maize', msp: 2225, mandiPrice: 2300, unit: 'quintal'),
  MspCropModel(crop: 'Tur (Arhar)', msp: 7000, mandiPrice: 6400, unit: 'quintal'),
  MspCropModel(crop: 'Moong', msp: 7550, mandiPrice: 7200, unit: 'quintal'),
  MspCropModel(crop: 'Groundnut', msp: 5550, mandiPrice: 5100, unit: 'quintal'),
];

class MspSupportScreen extends StatefulWidget {
  const MspSupportScreen({super.key});

  @override
  State<MspSupportScreen> createState() => _MspSupportScreenState();
}

class _MspSupportScreenState extends State<MspSupportScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'MSP Support & Grievance',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live MSP Dashboard
            Text('Live MSP Dashboard', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _headerRow(),
                  const Divider(),
                  ...kMspCrops.map(_cropRow),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Grievance Filing
            Text('File MSP Grievance', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
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
                    'If you are being offered prices below MSP at a local mandi, file a grievance. '
                    'It will be escalated to the District Agriculture Officer and State Agriculture Department.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.5),
                  ),
                  SizedBox(height: 16.h),

                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Crop Type', Icons.eco),
                    items: kMspCrops.map((c) => DropdownMenuItem(value: c.crop, child: Text(c.crop))).toList(),
                    onChanged: (_) {},
                  ),
                  SizedBox(height: 12.h),

                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Quantity (quintals)', Icons.scale),
                  ),
                  SizedBox(height: 12.h),

                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Price Offered (₹/quintal)', Icons.currency_rupee),
                  ),
                  SizedBox(height: 12.h),

                  TextField(
                    decoration: _inputDecoration('Mandi Name', Icons.store),
                  ),
                  SizedBox(height: 12.h),

                  TextField(
                    decoration: _inputDecoration('Additional Details / Evidence', Icons.description),
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
                        const SnackBar(content: Text('Grievance filed! Escalated to District Agriculture Officer.')),
                      );
                    },
                    child: Text('Submit Grievance',
                        style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerRow() {
    return const Row(
      children: [
        Expanded(flex: 2, child: Text('Crop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(flex: 1, child: Text('MSP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(flex: 1, child: Text('Mandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
      ],
    );
  }

  Widget _cropRow(MspCropModel crop) {
    final isBelowMsp = crop.mandiPrice < crop.msp;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(crop.crop, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 1,
            child: Text('₹${crop.msp.toStringAsFixed(0)}', style: TextStyle(fontSize: 13.sp)),
          ),
          Expanded(
            flex: 1,
            child: Text('₹${crop.mandiPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 13.sp)),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: (isBelowMsp ? Colors.red : Colors.green).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                isBelowMsp ? 'Below MSP' : 'OK',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isBelowMsp ? Colors.red.shade700 : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
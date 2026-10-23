import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// MSME B2B Wholesale & Employee Desk - ACCESS RESTRICTED TO: MSMES ONLY.
///
/// Header shows enterprise name, GST/registration ID and the mandatory
/// employee_count tracking badge. Includes bulk order bidding board,
/// negotiation desk, employee metric management and the compliance vault.
class MsmeB2bDeskScreen extends StatefulWidget {
  const MsmeB2bDeskScreen({super.key});

  @override
  State<MsmeB2bDeskScreen> createState() => _MsmeB2bDeskScreenState();
}

class _MsmeB2bDeskScreenState extends State<MsmeB2bDeskScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  int _employeeCount = 24;
  final _employeeCountController = TextEditingController(text: '24');

  final List<(String, String, String)> _bulkOrders = const [
    ('Organic Pulse Flour', '50 MT | Rs 62/kg tiered', '12 bids'),
    ('Cold-Pressed Groundnut Oil', '8,000 L | Rs 178/L tiered', '7 bids'),
    ('Jute Packaging Sacks', '1,00,000 units', '21 bids'),
  ];

  final List<(String, String)> _complianceDocs = const [
    ('Pollution Certificate', 'Valid till 04/2027'),
    ('FSSAI Food Safety License', 'Valid till 11/2026'),
    ('Export Registration (IEC)', 'Verified'),
  ];

  @override
  void dispose() {
    _employeeCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('MSME B2B & Employee Desk',
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
                  colors: [Color(0xFF1A73E8), _primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.factory_outlined, color: Colors.white, size: 32.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shree Balaji Agro Processing',
                            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text('GST: 27ABCDE1234F1Z5', style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20.r)),
                    child: Text('employee_count: $_employeeCount',
                        style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _sectionTitle('Bulk Order Bidding Board'),
            ..._bulkOrders.map((o) => Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_outlined, color: Color(0xFF1A73E8)),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(o.$1, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                          Text(o.$2, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                        ]),
                      ),
                      Column(children: [
                        Text(o.$3, style: TextStyle(fontSize: 11.sp, color: _primaryGreen, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryGreen,
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              minimumSize: Size.zero),
                          onPressed: () {},
                          child: Text('Open Desk', style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                        ),
                      ]),
                    ],
                  ),
                )),
            SizedBox(height: 8.h),
            _sectionTitle('Negotiation Desk'),
            _infoTile(Icons.chat_outlined, 'Private price-quote messaging and contract drafting',
                'Direct 1:1 negotiation with verified commercial buyers.'),
            SizedBox(height: 8.h),
            _sectionTitle('Employee Metric Management'),
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
                  Text('Update total employee_count', style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                  SizedBox(height: 10.h),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _employeeCountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Employee count',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
                      onPressed: () {
                        final v = int.tryParse(_employeeCountController.text.trim());
                        if (v != null && v >= 0) setState(() => _employeeCount = v);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('employee_count updated to $_employeeCount. Worker credentials re-issued.')));
                      },
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ]),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            _sectionTitle('Industrial Compliance Vault'),
            ..._complianceDocs.map((d) => _infoTile(Icons.verified_user_outlined, d.$1, d.$2)),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text(t, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
      );

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(children: [
        Icon(icon, color: _primaryGreen),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
          ]),
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Organization 30-Seat Admin Dashboard - ACCESS RESTRICTED TO:
/// ORGANIZATIONS (FPOs, Cooperatives, Collectives) with an active
/// Enterprise Plan (Rs 100,000/yr).
///
/// Header shows the organization title, FPO license and the mandatory
/// member_count counter. Includes the 30-seat member allocation desk,
/// aggregated inventory consolidation, member benefit distribution log and
/// the analytics & governance suite.
class OrgAdminDashboardScreen extends StatefulWidget {
  const OrgAdminDashboardScreen({super.key});

  @override
  State<OrgAdminDashboardScreen> createState() => _OrgAdminDashboardScreenState();
}

class _OrgAdminDashboardScreenState extends State<OrgAdminDashboardScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  final int _memberCount = 214;
  final Set<int> _seats = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};

  final List<(String, String)> _distributionLog = const [
    ('Payout distribution - Oct harvest pool', 'Rs 8,42,000 across 96 members'),
    ('Subsidized input allocation (urea, seeds)', '124 member allotments'),
    ('Collective loan disbursement - FPO credit line', 'Rs 15,00,000 | 2 tranches'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('Org 30-Seat Admin Console',
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
                  colors: [Color(0xFFB8860B), _primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 32.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Kaveri Farmer Producers Co-op',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text('FPO License: FPO-KA-2019-4471',
                          style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                    ]),
                  ),
                  Column(children: [
                    Text('$_memberCount', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    Text('member_count', style: TextStyle(color: Colors.white70, fontSize: 9.sp)),
                  ]),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _section('30-Seat Member Allocation Desk', 'Invite, assign or revoke platform access across 30 enterprise staff or lead farmers.'),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(children: [
                Text('Allocated seats: ${_seats.length} / 30',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                SizedBox(height: 10.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 30,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10, mainAxisSpacing: 6, crossAxisSpacing: 6),
                  itemBuilder: (context, i) {
                    final seat = i + 1;
                    final taken = _seats.contains(seat);
                    return InkWell(
                      onTap: () => setState(() => taken ? _seats.remove(seat) : _seats.add(seat)),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: taken ? _primaryGreen : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('$seat',
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: taken ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                Text('Tap a seat to invite / revoke team manager access.',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600])),
              ]),
            ),
            SizedBox(height: 12.h),
            _section('Aggregated Inventory Consolidation',
                'Combine crop or craft yields from hundreds of members into single bulk market listings.'),
            _infoTile(Icons.merge_type_outlined, 'Current consolidated lot',
                '386 t soybean + 54 t turmeric across 12 villages'),
            SizedBox(height: 8.h),
            _section('Member Benefit Distribution Log',
                'Track payout distributions, subsidized input allocations and collective loan disbursements.'),
            ..._distributionLog.map((d) => _infoTile(Icons.receipt_long_outlined, d.$1, d.$2)),
            SizedBox(height: 8.h),
            _section('Analytics & Governance Suite',
                'Export audit-ready revenue, export and escrow transaction reports.'),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, color: Colors.white),
                  label: const Text('Export Reports', style: TextStyle(color: Colors.white)),
                ),
              ),
            ]),
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

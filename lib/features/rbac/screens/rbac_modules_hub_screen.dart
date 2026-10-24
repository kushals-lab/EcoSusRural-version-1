import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/rbac/rbac.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../circular_economy/screens/circular_economy_screen.dart';
import '../../expert_advice/screens/expert_advice_screen.dart';
import '../../marketplace/screens/marketplace_screen.dart';
import '../../payments/screens/wallet_screen.dart';
import '../../schemes/screens/schemes_screen.dart';
import '../../smart_dryer/screens/smart_dryer_screen.dart';
import 'artisan_gi_registry_screen.dart';
import 'farmer_soil_lab_screen.dart';
import 'msme_b2b_desk_screen.dart';
import 'org_admin_dashboard_screen.dart';

/// Category Modules Hub - RBAC surface for the EcoSusRural platform.
///
/// Shows the four category-restricted modules (gated by the selected
/// persona) and the universal services available to everyone, per the
/// platform permission & access control matrix.
class RbacModulesHubScreen extends StatefulWidget {
  const RbacModulesHubScreen({super.key});

  @override
  State<RbacModulesHubScreen> createState() => _RbacModulesHubScreenState();
}

class _RbacModulesHubScreenState extends State<RbacModulesHubScreen> {
  static const Color _primaryGreen = Color(0xFF1B4D3E);

  EcoRole _role = EcoRole.buyer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('Category Modules (RBAC)',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who is using the platform?',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: EcoRole.values.map((r) {
                final selected = _role == r;
                return ChoiceChip(
                  avatar: Icon(r.icon, size: 16, color: selected ? Colors.white : _primaryGreen),
                  label: Text(r.label),
                  selected: selected,
                  selectedColor: _primaryGreen,
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                  onSelected: (_) => setState(() => _role = r),
                );
              }).toList(),
            ),
            SizedBox(height: 6.h),
            Text('Role: ${_role.label}',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
            SizedBox(height: 16.h),
            Text('Category-Restricted Modules',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 10.h),
            ...RestrictedModule.values.map((m) => _moduleCard(m)),
            SizedBox(height: 16.h),
            Text('Universal Access - For Everyone',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 10.h),
            ...kUniversalServices.map((s) => _universalCard(s.$1, s.$2, s.$3, s.$4)),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(RestrictedModule m) {
    final allowed = moduleAllowed(_role, m);
    final allowedRoleLabels = m.allowedRoles.map((role) => role.label).join(' or ');
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: allowed ? m.color : Colors.grey.shade300, width: allowed ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(color: m.color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(m.icon, color: m.color, size: 22.r),
            ),
            SizedBox(width: 10.w),
            Expanded(child: Text(m.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: allowed ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(allowed ? Icons.lock_open : Icons.lock, size: 12, color: allowed ? Colors.green : Colors.orange),
                SizedBox(width: 4.w),
                Text(allowed ? 'Unlocked' : 'Locked',
                    style: TextStyle(fontSize: 10.sp, color: allowed ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
          SizedBox(height: 8.h),
          Text(m.subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600], height: 1.4)),
          SizedBox(height: 4.h),
          Text('Access restricted to: $allowedRoleLabels',
              style: TextStyle(fontSize: 11.sp, color: m.color, fontWeight: FontWeight.w600)),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: allowed ? m.color : Colors.grey.shade400,
                padding: EdgeInsets.symmetric(vertical: 10.h),
              ),
              onPressed: () => _openModule(m),
              child: Text(allowed ? 'Open Module' : 'Access Denied',
                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _openModule(RestrictedModule m) {
    if (!moduleAllowed(_role, m)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orange.shade800,
        content: Text(
            '${m.title} is for ${m.allowedRoles.map((role) => role.label).join(' or ')} accounts. Switch persona to continue.'),
      ));
      return;
    }
    final Widget screen;
    switch (m) {
      case RestrictedModule.soilLab:
        screen = const FarmerSoilLabScreen();
      case RestrictedModule.b2bDesk:
        screen = const MsmeB2bDeskScreen();
      case RestrictedModule.giRegistry:
        screen = const ArtisanGiRegistryScreen();
      case RestrictedModule.orgConsole:
        screen = const OrgAdminDashboardScreen();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _universalCard(String title, IconData icon, Color color, String audience) {
    final routes = {
      'EcoSusRural AI Assistant': () => const AiAssistantScreen(),
      'Marketplace': () => const MarketplaceScreen(),
      'Circular Economy': () => const CircularEconomyScreen(),
      'EcoBharatPay': () => const WalletScreen(),
      'Expert Advice': () => const ExpertAdviceScreen(),
      'Schemes, Loans, Insurance & Scholarships': () => const SchemesScreen(),
      'Smart Solar Dryer': () => const SmartDryerScreen(),
    };
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            final build = routes[title];
            if (build != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => build()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
            }
          },
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(children: [
              Icon(icon, color: color),
              SizedBox(width: 12.w),
              Expanded(child: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10.r)),
                child: Text(audience, style: TextStyle(fontSize: 10.sp, color: Colors.green.shade700)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

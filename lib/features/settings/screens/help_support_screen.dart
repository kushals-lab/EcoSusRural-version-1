import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';

/// Consumer Helpdesk (24/7 Helpline) — previously a SnackBar-only tile in
/// Settings. Now a real page that stays inside the app so the user can read
/// it and come back to exactly where they left off.
class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ref.tr('helpSupport'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Container(
            padding: EdgeInsets.all(18.r),
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
                Row(
                  children: [
                    const Icon(Icons.headset_mic, color: Colors.amber, size: 28),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Consumer Helpdesk (24/7 Helpline)',
                        style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Multi-lingual IVR & WhatsApp escalation support in your chosen language.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.sp, height: 1.4),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _tile(
            context,
            icon: Icons.call,
            title: 'Toll-free IVR Helpline',
            subtitle: 'Tap to simulate connecting in your chosen language',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting to toll-free IVR in your chosen language...')),
              );
            },
          ),
          _tile(
            context,
            icon: Icons.chat,
            title: 'WhatsApp Escalation',
            subtitle: 'Raise a ticket and track escalation status',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening WhatsApp escalation thread...')),
              );
            },
          ),
          _tile(
            context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@ecosusrural.in (replies within 24 hours)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Drafting support email...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: _primaryGreen),
          title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}

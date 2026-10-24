import '../../marketplace/screens/offline_workspace_screen.dart';
import '../../weather/screens/location_selection_screen.dart';
import '../../clock/clock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../../language/screens/language_gateway_screen.dart';
import '../../legal/screens/ethics_integrity_pledge_screen.dart';
import '../../legal/screens/legal_agreement_screen.dart';
import '../../presentation/onboarding_tutorial_screen.dart';
import 'help_support_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  bool _notificationsEnabled = true;
  bool _lowDataMode = false;
  bool _highContrastMode = false;
  bool _biometricLogin = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider.select((s) => s.code));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          ref.tr('settings'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          ListTile(leading: const Icon(Icons.offline_pin), title: const Text('Offline library & product drafts'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineWorkspaceScreen()))),
          ListTile(leading: const Icon(Icons.location_on), title: const Text('Location preferences'), subtitle: const Text('Weather, farm, business and market'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationSelectionScreen()))),
          ListTile(leading: const Icon(Icons.alarm), title: const Text('Reminders, alarms, timer and world clock'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClockScreen()))),
          _buildSectionHeader(ref.tr('changeLanguage'), Icons.language),
          _buildSettingTile(
            icon: Icons.translate,
            title: ref.tr('selectLanguage'),
            subtitle: 'Current Active: ${lang.toUpperCase()}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const LanguageGatewayScreen(popAfterSelect: true)),
              );
            },
          ),
          SizedBox(height: 16.h),

          _buildSectionHeader('Notifications & Real-time Alerts', Icons.notifications),
          SwitchListTile(
            tileColor: Colors.white,
            secondary: Icon(Icons.notifications_active, color: _primaryGreen),
            title: const Text('Push Notifications'),
            subtitle: const Text('Mandi MSP updates, weather alerts, order delivery'),
            value: _notificationsEnabled,
            activeThumbColor: _primaryGreen,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          SizedBox(height: 16.h),

          _buildSectionHeader('Accessibility & Low-Bandwidth (2G/3G)', Icons.accessibility_new),
          SwitchListTile(
            tileColor: Colors.white,
            secondary: Icon(Icons.network_cell, color: _primaryGreen),
            title: const Text('Low Data Mode'),
            subtitle: const Text('Minimal data consumption mode for 2G/3G rural networks'),
            value: _lowDataMode,
            activeThumbColor: _primaryGreen,
            onChanged: (v) => setState(() => _lowDataMode = v),
          ),
          SwitchListTile(
            tileColor: Colors.white,
            secondary: Icon(Icons.visibility, color: _primaryGreen),
            title: const Text('High Contrast & Large Text'),
            subtitle: const Text('WCAG 2.1 AA accessible typography'),
            value: _highContrastMode,
            activeThumbColor: _primaryGreen,
            onChanged: (v) => setState(() => _highContrastMode = v),
          ),
          SwitchListTile(
            tileColor: Colors.white,
            secondary: Icon(Icons.fingerprint, color: _primaryGreen),
            title: const Text('Biometric Quick Login'),
            subtitle: const Text('Fingerprint / Face ID for instant persistent login'),
            value: _biometricLogin,
            activeThumbColor: _primaryGreen,
            onChanged: (v) => setState(() => _biometricLogin = v),
          ),
          SizedBox(height: 16.h),

          _buildSectionHeader('Ethics, Integrity & Content DRM', Icons.security),
          _buildSettingTile(
            icon: Icons.verified_user_rounded,
            title: ref.tr('ethicsPledge'),
            subtitle: 'Anti-counterfeiting, GI tags, fair pricing guarantee',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EthicsIntegrityPledgeScreen()),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.lock,
            title: 'Privacy Policy & DPDPA 2023',
            subtitle: 'Encrypted India data residency (AES-256 / TLS 1.3)',
            onTap: () {
              // Re-read mode: shows the same legal document but returns to
              // Settings instead of forcing login/registration.
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const LegalAgreementScreen(isReadOnly: true)),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Marketplace rules, ethics compact & content policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const LegalAgreementScreen(isReadOnly: true)),
              );
            },
          ),
          SizedBox(height: 16.h),

          _buildSectionHeader('Tutorial & Consumer Support', Icons.support_agent),
          _buildSettingTile(
            icon: Icons.replay_circle_filled,
            title: ref.tr('revisitTutorial'),
            subtitle: 'Replay the 4-step app walkthrough anytime',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingTutorialScreen()),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.headset_mic,
            title: 'Consumer Helpdesk (24/7 Helpline)',
            subtitle: 'Multi-lingual IVR & WhatsApp escalation support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          SizedBox(height: 16.h),

          Container(
            margin: EdgeInsets.only(top: 8.h),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout?'),
                    content: const Text('Your session will be cleared. You will need to login again with OTP.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(ref.tr('cancel')),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out successfully.')),
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, color: _primaryGreen, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
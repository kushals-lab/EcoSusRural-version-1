import '../../marketplace/screens/offline_workspace_screen.dart';
import '../../weather/screens/location_selection_screen.dart';
import '../../clock/clock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/language_provider.dart';
import '../../language/screens/language_gateway_screen.dart';
import '../../legal/screens/ethics_integrity_pledge_screen.dart';
import '../../legal/screens/legal_agreement_screen.dart';
import '../../presentation/onboarding_tutorial_screen.dart';
import 'help_support_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _tr(String key) => ref.read(languageProvider.notifier)
      .translate(key, ref.read(languageProvider).code);
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  bool _notificationsEnabled = true;
  bool _lowDataMode = false;
  bool _highContrastMode = false;
  bool _biometricLogin = false;

  @override
  void initState() {
    super.initState();
    _restoreSettings();
  }

  Future<void> _restoreSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('ecosus.settings.notifications') ?? true;
      _lowDataMode = prefs.getBool('ecosus.settings.lowData') ?? false;
      _highContrastMode = prefs.getBool('ecosus.settings.highContrast') ?? false;
      _biometricLogin = prefs.getBool('ecosus.settings.biometric') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ecosus.settings.$key', value);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider.select((s) => s.code));
    final l10n = (lang == 'en' || lang == 'hi')
        ? AppLocalizations.of(context) : null;

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
          ListTile(leading: const Icon(Icons.offline_pin), title: Text(l10n?.offlineLibraryDrafts ?? ref.tr('offlineLibraryDrafts')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineWorkspaceScreen()))),
          ListTile(leading: const Icon(Icons.location_on), title: Text(ref.tr('locationPreferences')), subtitle: Text(ref.tr('locationPurposes')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationSelectionScreen()))),
          ListTile(leading: const Icon(Icons.alarm), title: Text(ref.tr('remindersClock')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClockScreen()))),
          _buildSectionHeader(ref.tr('changeLanguage'), Icons.language),
          _buildSettingTile(
            icon: Icons.translate,
            title: ref.tr('selectLanguage'),
            subtitle: l10n?.currentActive(lang.toUpperCase()) ?? ref.tr('currentActive', {'language': lang.toUpperCase()}),
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

          _buildSectionHeader(ref.tr('notificationsAlerts'), Icons.notifications),
          SwitchListTile(
            tileColor: Colors.white,
            secondary: Icon(Icons.notifications_active, color: _primaryGreen),
            title: Text(ref.tr('pushNotifications')),
            subtitle: Text(ref.tr('notificationDetails')),
            value: _notificationsEnabled,
            activeThumbColor: _primaryGreen,
            onChanged: (v) { setState(() => _notificationsEnabled = v); _saveSetting('notifications', v); },
          ),
          SizedBox(height: 16.h),

          _buildSectionHeader(ref.tr('accessibilityLowData'), Icons.accessibility_new),
          SwitchListTile(
            tileColor: Colors.white,
            secondary: Icon(Icons.network_cell, color: _primaryGreen),
            title: Text(ref.tr('lowDataMode')),
            subtitle: Text(ref.tr('lowDataDetails')),
            value: _lowDataMode,
            activeThumbColor: _primaryGreen,
            onChanged: (v) { setState(() => _lowDataMode = v); _saveSetting('lowData', v); },
          ),
          SwitchListTile(
            tileColor: Colors.white,
            secondary: Icon(Icons.visibility, color: _primaryGreen),
            title: Text(ref.tr('highContrast')),
            subtitle: Text(ref.tr('highContrastDetails')),
            value: _highContrastMode,
            activeThumbColor: _primaryGreen,
            onChanged: (v) { setState(() => _highContrastMode = v); _saveSetting('highContrast', v); },
          ),
          SwitchListTile(
            tileColor: Colors.white,
            secondary: Icon(Icons.fingerprint, color: _primaryGreen),
            title: Text(ref.tr('biometricQuickLogin')),
            subtitle: Text(ref.tr('biometricDetails')),
            value: _biometricLogin,
            activeThumbColor: _primaryGreen,
            onChanged: (v) { setState(() => _biometricLogin = v); _saveSetting('biometric', v); },
          ),
          SizedBox(height: 16.h),

          _buildSectionHeader(ref.tr('ethicsContent'), Icons.security),
          _buildSettingTile(
            icon: Icons.verified_user_rounded,
            title: ref.tr('ethicsPledge'),
            subtitle: ref.tr('ethicsDetails'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EthicsIntegrityPledgeScreen()),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.lock,
            title: '${ref.tr('privacyPolicy')} & DPDPA 2023',
            subtitle: ref.tr('privacyDetails'),
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
            title: ref.tr('termsConditions'),
            subtitle: ref.tr('termsDetails'),
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

          _buildSectionHeader(ref.tr('tutorialSupport'), Icons.support_agent),
          _buildSettingTile(
            icon: Icons.replay_circle_filled,
            title: ref.tr('revisitTutorial'),
            subtitle: ref.tr('tutorialDetails'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingTutorialScreen()),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.headset_mic,
            title: ref.tr('consumerHelpdesk'),
            subtitle: ref.tr('helpdeskDetails'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          SizedBox(height: 16.h),

          _buildSectionHeader(ref.tr('appUpdates'), Icons.system_update),
          _buildSettingTile(
            icon: Icons.system_update,
            title: ref.tr('checkUpdates'),
            subtitle: ref.tr('updatesSubtitle'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.system_update, color: Color(0xFF1B4D3E)),
                      SizedBox(width: 8),
                      Text('EcoSusRural'),
                    ],
                  ),
                  content: Text(_tr('updateInfo')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(_tr('ok')),
                    ),
                  ],
                ),
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
                    title: Text(_tr('logoutQuestion')),
                    content: Text(_tr('logoutDetails')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(_tr('cancel')),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref.read(authProvider.notifier).reset();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_tr('loggedOut'))),
                          );
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LanguageGatewayScreen()),
                            (_) => false,
                          );
                        },
                        child: Text(_tr('logoutAction')),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(ref.tr('logoutAction'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
              softWrap: true,
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

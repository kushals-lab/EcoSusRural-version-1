/// Comprehensive dryer suite: hosts spec Pages A-F with a role-aware
/// drawer + IndexedStack so each page keeps its own scroll/state.
/// The legacy 4-tab SmartDryerScreen is retained for its widget test.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/rbac/rbac.dart';
import '../domain/dryer_access.dart';
import 'crop_profile_page.dart';
import 'dryer_home_page.dart';
import 'dryer_live_page.dart';
import 'dryer_manual_page.dart';
import 'dryer_session_page.dart';
import 'dryer_settings_page.dart';
class DryerSuiteScreen extends ConsumerStatefulWidget {
  const DryerSuiteScreen({super.key});
  @override
  ConsumerState<DryerSuiteScreen> createState() =>
      _DryerSuiteScreenState();
}
class _DryerSuiteScreenState extends ConsumerState<DryerSuiteScreen> {
  int _idx = 0;
  EcoRole role = EcoRole.farmer;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  void _go(int i) {
    setState(() => _idx = i);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B4D3E);
    final access = dryerAccessFor(role);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 1,
        centerTitle: true,
        title: const Text('Smart Solar Dryer',
          style: TextStyle(fontWeight: FontWeight.bold, color: green)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<EcoRole>(value: role, underline:
              const SizedBox(),
              items: [for (final r in EcoRole.values)
                DropdownMenuItem(value: r, child: Text(r.label))],
              onChanged: (v) =>
                setState(() => role = v ?? role))),
        ]),
      drawer: Drawer(child: ListView(children: [
        DrawerHeader(decoration: const BoxDecoration(color: green),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Smart Solar Dryer',
              style: TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Access: ${access.label}',
              style: const TextStyle(color: Colors.white70)),
            const Text('ESP32 - BLE / Wi-Fi / offline',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
        _nav(Icons.home, 'Home', 0),
        _nav(Icons.grass, 'Crop profiles', 1),
        _nav(Icons.monitor_heart, 'Live monitoring', 2),
        _nav(Icons.tune, 'Manual control', 3),
        _nav(Icons.timeline, 'Session', 4),
        _nav(Icons.settings, 'Settings & calibration', 5),
      ])),
      body: IndexedStack(index: _idx, children: [
        DryerHomePage(onOpenCrops: () => _go(1),
          onOpenLive: () => _go(2),
          onOpenSession: () => _go(4),
          onOpenSettings: () => _go(5)),
        const CropProfilePage(),
        const DryerLivePage(),
        DryerManualPage(access: access),
        const DryerSessionPage(),
        DryerSettingsPage(access: access),
      ]),
    );
  }
  Widget _nav(IconData i, String t, int idx) => ListTile(
    leading: Icon(i, color: _idx == idx ? const Color(0xFF1B4D3E)
      : null),
    title: Text(t, style: TextStyle(fontWeight:
      _idx == idx ? FontWeight.bold : FontWeight.normal)),
    selected: _idx == idx,
    onTap: () => _go(idx));
}

/// Smart Solar Dryer shell: role-aware tabs reusing app theme.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dryer_access.dart';
import 'dryer_batch_list_tab.dart';
import 'dryer_control_tab.dart';
import 'dryer_history_tab.dart';
import 'dryer_monitor_tab.dart';
import 'dryer_connect_sheet.dart';
import '../domain/dryer_state.dart';
class SmartDryerScreen extends ConsumerStatefulWidget {
  const SmartDryerScreen({super.key});
  @override
  ConsumerState<SmartDryerScreen> createState() =>
      _SmartDryerScreenState();
}
class _SmartDryerScreenState extends ConsumerState<SmartDryerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs;
  String role = 'farmer';
  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 4, vsync: this);
  }
  @override
  void dispose() { tabs.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B4D3E);
    final access = dryerAccessFor(role);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(backgroundColor: Colors.white,
        elevation: 1, centerTitle: true,
        title: const Text('Smart Solar Dryer',
            style: TextStyle(fontWeight: FontWeight.bold,
                color: green)),
        actions: [IconButton(tooltip: 'Connect HTML simulator', icon: const Icon(Icons.science_outlined),
          onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true,
            builder: (_) => const DryerConnectSheet(initialKind: DryerTransportKind.htmlSimulator)))],
        bottom: TabBar(controller: tabs, labelColor: green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Monitor'), Tab(text: 'Control'),
            Tab(text: 'Batch'), Tab(text: 'History'),
          ])),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(children: [
            const Text('Role:', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                value: role,
                underline: const SizedBox(),
                items: ['farmer', 'msme', 'organization', 'artisan', 'buyer']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => role = v ?? role),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Dryer access: ${access.label}',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 12))),
          ])),
        Expanded(child: TabBarView(controller: tabs, children: [
          DryerMonitorTab(access: access),
          DryerControlTab(access: access),
          DryerBatchListTab(access: access),
          const DryerHistoryTab(),
        ])),
      ]),
    );
  }
}

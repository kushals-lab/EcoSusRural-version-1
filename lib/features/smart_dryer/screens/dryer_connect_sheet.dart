/// Connect sheet: transport pick + scan + connect.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../data/simulator_transport.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_state.dart';
import '../providers/dryer_providers.dart';
class DryerConnectSheet extends ConsumerStatefulWidget {
  const DryerConnectSheet({super.key, this.initialKind});
  final DryerTransportKind? initialKind;
  @override
  ConsumerState<DryerConnectSheet> createState() =>
      _DryerConnectSheetState();
}
class _DryerConnectSheetState
    extends ConsumerState<DryerConnectSheet> {
  List<DryerDeviceInfo> found = [];
  bool busy = false;
  String? err;
  final _code = TextEditingController();
  @override void initState() {
    super.initState();
    if (widget.initialKind != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) pick(widget.initialKind!);
      });
    }
  }
  @override void dispose() { _code.dispose(); super.dispose(); }
  Future<void> pick(DryerTransportKind k) async {
    setState(() { busy = true; err = null; found = []; });
    try {
      ref.read(dryerRepositoryProvider).useTransport(k);
      found = await ref.read(dryerRepositoryProvider).scan();
    } catch (e) { err = '$e'; }
    if (mounted) setState(() { busy = false; });
  }
  Future<void> pairSimulation() async {
    setState(() { busy = true; err = null; });
    try {
      final repo = ref.read(dryerRepositoryProvider);
      final transport = repo.transport as SimulatorDryerTransport;
      final device = await transport.pair(_code.text.trim());
      await repo.connect(device);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) setState(() => err = error is StateError ? error.message.toString() : 'Could not reach the HTML simulator. Check the backend connection.');
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    final repo = ref.read(dryerRepositoryProvider);
    return SafeArea(child: SingleChildScrollView(child: Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connect dryer',
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final k in DryerTransportKind.values)
              ChoiceChip(label: Text(k == DryerTransportKind.htmlSimulator ? 'HTML simulator' : k.name),
                  selected: repo.transport.kind == k,
                  onSelected: busy ? null : (_) => pick(k)),
          ]),
          const SizedBox(height: 8),
          if (busy) const LinearProgressIndicator(),
          if (err != null)
            Text(err!, style: const TextStyle(color: Colors.red)),
          if (repo.transport.kind == DryerTransportKind.htmlSimulator) ...[
            const SizedBox(height: 8),
            const Text('Open the HTML dryer simulator on your laptop and enter its six-digit pairing code. This connects simulated data, never physical hardware.'),
            const SizedBox(height: 12),
            TextField(controller: _code, enabled: !busy,
              keyboardType: TextInputType.number, maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Simulator pairing code', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: busy ? null : pairSimulation,
              icon: const Icon(Icons.science_outlined), label: const Text('Pair HTML simulator')),
          ],
          for (final d in found)
            ListTile(title: Text(d.name),
              subtitle: Text(d.deviceId),
              trailing: const Icon(Icons.link),
              onTap: () async {
                try {
                  await repo.connect(d);
                  if (context.mounted) Navigator.pop(context);
                } catch (_) { if (mounted) setState(() => err = 'Could not connect to this dryer.'); }
              }),
          TextButton(onPressed: () async {
            await repo.disconnect();
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Disconnect')),
        ]),
    )));
  }
}

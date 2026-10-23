/// Connect sheet: transport pick + scan + connect.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_state.dart';
import '../providers/dryer_providers.dart';
class DryerConnectSheet extends ConsumerStatefulWidget {
  const DryerConnectSheet({super.key});
  @override
  ConsumerState<DryerConnectSheet> createState() =>
      _DryerConnectSheetState();
}
class _DryerConnectSheetState
    extends ConsumerState<DryerConnectSheet> {
  List<DryerDeviceInfo> found = [];
  bool busy = false;
  String? err;
  Future<void> pick(DryerTransportKind k) async {
    setState(() { busy = true; err = null; });
    try {
      ref.read(dryerRepositoryProvider).useTransport(k);
      found = await ref.read(dryerRepositoryProvider).scan();
    } catch (e) { err = '$e'; }
    setState(() { busy = false; });
  }
  @override
  Widget build(BuildContext context) {
    final repo = ref.read(dryerRepositoryProvider);
    return SafeArea(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connect dryer',
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final k in DryerTransportKind.values)
              ChoiceChip(label: Text(k.name),
                  selected: repo.transport.kind == k,
                  onSelected: (_) => pick(k)),
          ]),
          const SizedBox(height: 8),
          if (busy) const LinearProgressIndicator(),
          if (err != null)
            Text(err!, style: const TextStyle(color: Colors.red)),
          for (final d in found)
            ListTile(title: Text(d.name),
              subtitle: Text(d.deviceId),
              trailing: const Icon(Icons.link),
              onTap: () async {
                await repo.connect(d);
                if (context.mounted) Navigator.pop(context);
              }),
          TextButton(onPressed: () async {
            await repo.disconnect();
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Disconnect')),
        ]),
    ));
  }
}

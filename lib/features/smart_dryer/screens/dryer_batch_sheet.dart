/// Batch sheet: validated crop/batch creation (never auto-starts).
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dryer_batch.dart';
import '../domain/dryer_calculations.dart';
import '../providers/dryer_providers.dart';
class DryerBatchSheet extends ConsumerStatefulWidget {
  const DryerBatchSheet({super.key});
  @override
  ConsumerState<DryerBatchSheet> createState() => _DryerBatchSheetState();
}
class _DryerBatchSheetState extends ConsumerState<DryerBatchSheet> {
  String crop = 'chillies';
  final customCtrl = TextEditingController();
  String profile = 'standard';
  final mass = TextEditingController(text: '50');
  final initMc = TextEditingController();
  final targetMc = TextEditingController();
  final notes = TextEditingController();
  String? err;
  @override
  void dispose() {
    mass.dispose(); initMc.dispose();
    targetMc.dispose(); notes.dispose(); customCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: EdgeInsets.only(bottom:
          MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New drying batch',
                style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 16)),
            DropdownButton<String>(value: crop,
              items: [for (final c in kDryerCrops)
                DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() => crop = v ?? crop)),
            if (crop == 'custom')
              TextField(controller: customCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Custom crop name')),
            TextField(controller: mass,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Initial mass (kg, ~50)')),
            TextField(controller: initMc,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Initial MC % (optional)')),
            TextField(controller: targetMc,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Target MC % (optional)')),
            DropdownButton<String>(value: profile,
              items: [for (final p in kDryerProfiles)
                DropdownMenuItem(value: p.id,
                    child: Text(p.title))],
              onChanged: (v) => setState(() => profile = v ?? profile)),
            TextField(controller: notes,
                decoration: const InputDecoration(
                    labelText: 'Operator notes')),
            if (err != null)
              Text(err!,
                  style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final m = double.tryParse(mass.text) ?? -1;
                final i = double.tryParse(initMc.text);
                final t = double.tryParse(targetMc.text);
                final msg = DryerCalculations.validateMoisture(
                    massKg: m, initialPct: i, targetPct: t);
                if (msg != null) {
                  setState(() => err = msg);
                  return;
                }
                final prof = kDryerProfiles.firstWhere(
                    (e) => e.id == profile);
                final b = DryerBatch(
                  id: DateTime.now().microsecondsSinceEpoch
                      .toString(),
                  cropType: crop,
                  customCropName: customCtrl.text.isEmpty
                      ? null : customCtrl.text,
                  initialMassKg: m, initialMoisturePct: i,
                  targetMoisturePct: t, profileId: profile,
                  operatorNotes: notes.text,
                  createdAt: DateTime.now(),
                  experimental: prof.experimental,
                );
                await ref.read(dryerBatchesProvider.notifier)
                    .upsert(b);
                ref.read(dryerRepositoryProvider).activeBatch = b;
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save batch (does not start dryer)'),
            ),
          ]),
        ),
      ));
  }
}

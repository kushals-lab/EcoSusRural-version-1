/// Page B: Crop Profile Manager — CRUD list, offline, source-backed.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dryer_extra_providers.dart';
import 'crop_profile_edit_sheet.dart';
class CropProfilePage extends ConsumerWidget {
  const CropProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(cropProfilesProvider);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Crop profiles',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const Text('Configurable, source-backed. Provisional profiles '
        'need confirmation before automatic operation.'),
      const SizedBox(height: 8),
      ElevatedButton.icon(icon: const Icon(Icons.add),
        label: const Text('New / edit crop'),
        onPressed: () => showModalBottomSheet(
          context: context, isScrollControlled: true,
          builder: (_) => const CropProfileEditSheet())),
      const SizedBox(height: 8),
      for (final p in profiles)
        Card(child: ExpansionTile(
          leading: const Icon(Icons.grass),
          title: Text(p.cropName +
            (p.variety != null ? ' (${p.variety})' : '')),
          subtitle: Text('${p.minTempC.toStringAsFixed(0)}-'
            '${p.maxTempC.toStringAsFixed(0)} C | fan ${p.fanPwm}% | '
            '~${p.hoursEst.toStringAsFixed(0)} h | ${p.source}'),
          children: [
            Padding(padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (p.provisional)
                  Container(padding: const EdgeInsets.all(8),
                    color: Colors.orange.shade100,
                    child: const Text('PROVISIONAL — verify locally '
                      'before automatic operation.')),
                Text('Absolute max: ${p.absMaxTempC.toStringAsFixed(0)} C '
                  '(firmware-enforced, never bypassed)'),
                Text('Airflow: ${p.airflowMode}'),
                if (p.targetMc != null)
                  Text('Target moisture: ${p.targetMc}% (wet basis)'),
                Text('Notes: ${p.notes}'),
                Text('Version: ${p.version} | '
                  'Updated: ${p.updatedAt.toIso8601String().substring(0, 10)}'),
                const SizedBox(height: 6),
                Row(children: [
                  TextButton(
                    onPressed: () => showModalBottomSheet(
                      context: context, isScrollControlled: true,
                      builder: (_) => CropProfileEditSheet(existing: p)),
                    child: const Text('Edit')),
                  TextButton(
                    onPressed: () => ref
                      .read(cropProfilesProvider.notifier).remove(p.id),
                    child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
                ]),
              ])),
          ],
        )),
      if (profiles.isEmpty) const Text('No profiles — create one.'),
    ]);
  }
}

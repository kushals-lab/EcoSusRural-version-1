/// History tab: batches, trend, CSV export (share via clipboard/snack).
library;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dryer_history_store.dart';
import '../domain/dryer_calculations.dart';
import '../providers/dryer_providers.dart';
import '../widgets/dryer_chart.dart';
class DryerHistoryTab extends ConsumerWidget {
  const DryerHistoryTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(dryerBatchesProvider);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Drying history',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const Text('Measured values are stored; water-removed is an estimate.'),
      const SizedBox(height: 8),
      for (final b in batches)
        Card(child: ExpansionTile(
          title: Text('${b.displayCrop} - ${b.initialMassKg} kg'),
          subtitle: Text('profile ${b.profileId}'),
          children: [
            FutureBuilder(
              future: ref.read(dryerHistoryProvider(b.id).future),
              builder: (context, snap) {
                final readings = snap.data ?? [];
                final water =
                    DryerCalculations.estimateWaterRemovedKg(b);
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DryerTrendChart(history: readings,
                          title: 'Batch trend'),
                      Text('Samples: ${readings.length}'),
                      Text('Est. water removed: '
                          '${water == null ? 'needs MC values' : '${water.toStringAsFixed(2)} kg (ESTIMATE)'}'),
                      Text(DryerHistoryStore.batchReportText(
                          b, readings, [], water)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Copy CSV'),
                        onPressed: () async {
                          final csv =
                              DryerHistoryStore.batchCsv(b, readings);
                          await Clipboard.setData(
                              ClipboardData(text: csv));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text(
                                        'CSV copied to clipboard')));
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        )),
      if (batches.isEmpty) const Text('No batches recorded yet.'),
    ]);
  }
}

/// Batch list tab (localized title + role gating).
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';
import '../domain/dryer_access.dart';
import '../providers/dryer_providers.dart';
import 'dryer_batch_sheet.dart';
class DryerBatchListTab extends ConsumerWidget {
  final DryerAccess access;
  const DryerBatchListTab({super.key, required this.access});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(dryerBatchesProvider);
    final tr = ref.tr;
    return ListView(padding: EdgeInsets.all(16.r), children: [
      Text(tr('smartDryerBatchTitle'),
          style: TextStyle(fontSize: 16.sp,
              fontWeight: FontWeight.bold)),
      SizedBox(height: 8.h),
      ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: Text(tr('smartDryerNewBatch')),
        onPressed: access.canOperate
            ? () => showModalBottomSheet(
                context: context, isScrollControlled: true,
                builder: (_) => const DryerBatchSheet())
            : null,
      ),
      if (!access.canOperate)
        const Padding(padding: EdgeInsets.only(top: 8),
            child: Text('Viewers cannot create batches.')),
      SizedBox(height: 12.h),
      for (final b in batches)
        Card(child: ListTile(
          leading: const Icon(Icons.agriculture),
          title: Text('${b.displayCrop} - ${b.initialMassKg} kg'),
          subtitle: Text('profile ${b.profileId}'
              '${b.experimental ? ' (experimental)' : ''}'),
        )),
      if (batches.isEmpty)
        const Text('No batches yet. Create one to begin.'),
    ]);
  }
}

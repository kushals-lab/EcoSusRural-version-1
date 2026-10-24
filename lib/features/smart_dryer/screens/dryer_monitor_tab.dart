/// Monitor tab: composes header + grid from live provider.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../domain/dryer_access.dart';
import '../domain/dryer_state.dart';
import '../providers/dryer_providers.dart';
import 'dryer_monitor_grid.dart';
import 'dryer_monitor_header.dart';
class DryerMonitorTab extends ConsumerWidget {
  final DryerAccess access;
  const DryerMonitorTab({super.key, required this.access});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(dryerLiveProvider);
    final batches = ref.watch(dryerBatchesProvider);
    final alerts = ref.watch(dryerAlertsProvider);
    return live.when(
      loading: () => const Center(
          child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (d) {
        final repo = ref.read(dryerRepositoryProvider);
        final batch = repo.activeBatch ??
            (batches.isNotEmpty ? batches.last : null);
        return ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            DryerMonitorHeader(
              access: access, state: d.state,
              deviceName: d.deviceName,
              transportName: d.transport.name.toUpperCase(),
              batchLabel:
                  batch == null ? 'No batch' : batch.displayCrop,
              lastUpdate: d.reading == null ? null :
                  'Last update: ${d.reading!.receivedAt.toLocal()}'
                  '${d.stale ? ' (STALE)' : ''}',
              isDemo: d.transport == DryerTransportKind.demo || d.transport == DryerTransportKind.htmlSimulator || d.reading?.fromDemo == true,
            ),
            SizedBox(height: 12.h),
            DryerMonitorGrid(reading: d.reading,
                stale: d.stale, alerts: alerts),
          ],
        );
      },
    );
  }
}

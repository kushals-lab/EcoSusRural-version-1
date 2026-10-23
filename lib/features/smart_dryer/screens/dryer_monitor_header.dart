/// Monitor header: status panel + connect/batch actions.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../domain/dryer_access.dart';
import '../domain/dryer_state.dart';
import 'dryer_batch_sheet.dart';
import 'dryer_connect_sheet.dart';
class DryerMonitorHeader extends ConsumerWidget {
  final DryerAccess access;
  final DryerState state;
  final String? deviceName;
  final String transportName;
  final String batchLabel;
  final String? lastUpdate;
  final bool isDemo;
  const DryerMonitorHeader({super.key,
    required this.access, required this.state,
    required this.deviceName, required this.transportName,
    required this.batchLabel, required this.lastUpdate,
    required this.isDemo});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      if (isDemo)
        Container(padding: EdgeInsets.all(10.r),
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.amber.shade700)),
          child: const Row(children: [
            Icon(Icons.science_outlined),
            SizedBox(width: 8),
            Expanded(child: Text(
                'DEMO MODE - simulated data, not hardware.',
                style: TextStyle(fontWeight: FontWeight.bold))),
          ])),
      Container(padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF2E7D32), Color(0xFF1B4D3E)]),
          borderRadius: BorderRadius.circular(16.r)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.label,
                  style: TextStyle(color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold)),
              Text('${deviceName ?? 'No device'} - '
                  '$transportName - $batchLabel',
                  style: TextStyle(color: Colors.white70,
                      fontSize: 12.sp)),
              SizedBox(height: 10.h),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                    icon: const Icon(Icons.link,
                        size: 16, color: Colors.white),
                    label: const Text('Connect',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (_) =>
                            const DryerConnectSheet()))),
                SizedBox(width: 8.w),
                Expanded(child: OutlinedButton(
                    onPressed: access.canOperate
                        ? () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) =>
                                const DryerBatchSheet())
                        : null,
                    child: const Text('New batch',
                        style: TextStyle(color: Colors.white)))),
              ]),
              if (lastUpdate != null)
                Text(lastUpdate!,
                    style: TextStyle(color: Colors.white70,
                        fontSize: 11.sp)),
            ])),
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../network/api_client.dart';

/// Unobtrusive top banner / pill displaying offline state with clean animations
class OfflineStatusBar extends ConsumerWidget {
  const OfflineStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netState = ref.watch(networkStatusProvider);

    if (netState.status == NetworkStatus.online) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.amber.shade900,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            netState.status == NetworkStatus.checking
                ? Icons.sync
                : Icons.cloud_off_rounded,
            color: Colors.white,
            size: 14.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            netState.status == NetworkStatus.checking
                ? 'Connecting to EcoSusRural network...'
                : 'Offline Mode • Showing saved records',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => ref.read(networkStatusProvider.notifier).checkConnectivity(),
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.amber.shade200,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

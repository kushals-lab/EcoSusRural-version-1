library permission_gate;

import 'package:flutter/material.dart';
import 'permission_types.dart';
import 'permission_manager.dart';

class PermissionGate extends StatelessWidget {
  final String feature;
  final Widget child;
  final Widget Function(BuildContext, FeaturePermission)? explain;
  const PermissionGate({
    super.key,
    required this.feature,
    required this.child,
    this.explain,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<AppPermission, bool>>(
      future: PermissionManager.instance.checkFeature(feature),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return child;
        }
        return child;
      },
    );
  }
}

Future<bool> ensureFeaturePermission(
  BuildContext context,
  String feature, {
  String Function(String key)? tr,
}) async {
  final fp = FeaturePermissionRegistry.forFeature(feature);
  if (fp == null) return true;
  final mgr = PermissionManager.instance;
  final missing = <AppPermission>[];
  for (final p in fp.requiredPermissions) {
    if (!await mgr.isGranted(p)) missing.add(p);
  }
  if (missing.isEmpty) return true;
  if (!context.mounted) return false;
  final t = tr ?? ((k) => k);
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t('permissionTitle')),
      content: Text(fp.whyNeeded),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t('permissionSkip')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(t('permissionAllow')),
        ),
      ],
    ),
  );
  if (ok != true) return !fp.locationIsEssential ? true : false;
  for (final p in missing) {
    await mgr.request(p);
  }
  return true;
}

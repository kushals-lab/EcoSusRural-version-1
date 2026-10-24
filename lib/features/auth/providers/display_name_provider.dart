import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';

final displayNameProvider = FutureProvider<String>((ref) async {
  ref.watch(authProvider.select((s) => s.user?.uid));
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('ecosus.auth.user')?.split('|').first;
  return uid == null ? '' : prefs.getString('ecosus.display_name.$uid') ?? '';
});

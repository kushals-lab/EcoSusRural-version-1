/// Extended providers: profiles, sessions, settings + existing live/alerts.
/// Riverpod, offline-first.
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/crop_profile_store.dart';
import '../data/dryer_session_store.dart';
import '../data/dryer_settings_store.dart';
import '../domain/battery_settings.dart';
import '../domain/crop_profile.dart';
import '../domain/dryer_session.dart';
export 'dryer_providers.dart';
export '../data/dryer_repository.dart';
export '../domain/dryer_state.dart';
final cropProfilesProvider =
    StateNotifierProvider<CropProfilesNotifier, List<CropProfile>>(
        (ref) => CropProfilesNotifier());
class CropProfilesNotifier extends StateNotifier<List<CropProfile>> {
  CropProfilesNotifier() : super([]) {
    _load();
  }
  Future<void> _load() async {
    state = await CropProfileStore.load();
  }
  Future<void> upsert(CropProfile c) async {
    await CropProfileStore.upsert(c);
    state = await CropProfileStore.load();
  }
  Future<void> remove(String id) async {
    await CropProfileStore.remove(id);
    state = await CropProfileStore.load();
  }
  Future<String?> importJson(String raw) async {
    try {
      final list = CropProfileStore.importJson(raw);
      for (final c in list) {
        if (c.validate() != null) {
          return 'Invalid profile ${c.id}: ${c.validate()}';
        }
      }
      await CropProfileStore.saveAll(list);
      state = list;
      return null;
    } catch (e) {
      return 'Import failed: $e';
    }
  }
}
final dryerSessionsProvider =
    StateNotifierProvider<DryerSessionsNotifier, List<DryerSession>>(
        (ref) => DryerSessionsNotifier());
class DryerSessionsNotifier extends StateNotifier<List<DryerSession>> {
  DryerSessionsNotifier() : super([]) {
    _load();
  }
  Future<void> _load() async {
    state = await DryerSessionStore.load();
  }
  Future<void> upsert(DryerSession s) async {
    await DryerSessionStore.upsert(s);
    state = await DryerSessionStore.load();
  }
}
final dryerSettingsProvider =
    StateNotifierProvider<DryerSettingsNotifier, DryerDeviceSettings>(
        (ref) => DryerSettingsNotifier());
class DryerSettingsNotifier
    extends StateNotifier<DryerDeviceSettings> {
  DryerSettingsNotifier() : super(const DryerDeviceSettings()) {
    _load();
  }
  Future<void> _load() async {
    state = await DryerSettingsStore.load();
  }
  Future<void> save(DryerDeviceSettings s, {String note = ''}) async {
    await DryerSettingsStore.save(s, note: note);
    state = s;
  }
}

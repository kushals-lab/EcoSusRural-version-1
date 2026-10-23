/// Extended providers: profiles, sessions, settings + existing live/alerts.
/// Riverpod, offline-first.
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/crop_profile_store.dart';
import '../data/dryer_history_store.dart';
import '../data/dryer_repository.dart';
import '../data/dryer_session_store.dart';
import '../data/dryer_settings_store.dart';
import '../domain/battery_settings.dart';
import '../domain/crop_profile.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_batch.dart';
import '../domain/dryer_reading.dart';
import '../domain/dryer_session.dart';
import '../domain/dryer_state.dart';
export '../data/dryer_repository.dart';
export '../domain/dryer_state.dart';
final dryerRepositoryProvider =
    Provider<DryerRepository>((ref) {
  final repo = DryerRepository();
  ref.onDispose(repo.dispose);
  return repo;
});
class DryerLiveState {
  final DryerState state;
  final DryerReading? reading;
  final bool stale;
  final DryerTransportKind transport;
  final String? deviceName;
  const DryerLiveState({
    required this.state, this.reading, this.stale = false,
    required this.transport, this.deviceName,
  });
}
final dryerLiveProvider =
    StreamProvider<DryerLiveState>((ref) async* {
  final repo = ref.watch(dryerRepositoryProvider);
  DryerState state = repo.lastState;
  DryerReading? reading = repo.lastReading;
  yield DryerLiveState(state: state, reading: reading,
      transport: repo.transport.kind,
      deviceName: repo.transport.device?.name);
  await for (final _ in repo.readings) {
    reading = repo.lastReading;
    final stale = reading == null ? true : DateTime.now()
        .difference(reading.receivedAt).inSeconds > 30;
    yield DryerLiveState(state: repo.lastState, reading: reading,
        stale: stale, transport: repo.transport.kind,
        deviceName: repo.transport.device?.name);
  }
});
final dryerAlertsProvider =
    StateNotifierProvider<DryerAlertsNotifier, List<DryerAlert>>(
        (ref) => DryerAlertsNotifier(ref));
class DryerAlertsNotifier extends StateNotifier<List<DryerAlert>> {
  final Ref _ref;
  DryerAlertsNotifier(this._ref) : super([]) {
    final repo = _ref.read(dryerRepositoryProvider);
    repo.alerts.listen((a) {
      state = [...state, a].take(100).toList();
    });
  }
  void addLocal(String code, String message) {
    state = [...state, DryerAlert(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      code: code, message: message, raisedAt: DateTime.now(),
    )].take(100).toList();
  }
  void clear() => state = [];
}
final dryerBatchesProvider =
    StateNotifierProvider<DryerBatchesNotifier, List<DryerBatch>>(
        (ref) => DryerBatchesNotifier());
class DryerBatchesNotifier extends StateNotifier<List<DryerBatch>> {
  DryerBatchesNotifier() : super([]) {
    _load();
  }
  Future<void> _load() async {
    state = await DryerHistoryStore.loadBatches();
  }
  Future<void> upsert(DryerBatch b) async {
    await DryerHistoryStore.saveBatch(b);
    state = await DryerHistoryStore.loadBatches();
  }
}
final dryerHistoryProvider =
    FutureProvider.family<List<DryerReading>, String>((ref, batchId) {
  return DryerHistoryStore.loadReadings(batchId);
});
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

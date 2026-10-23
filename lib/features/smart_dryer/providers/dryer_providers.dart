/// Riverpod providers for the Smart Dryer feature.
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dryer_history_store.dart';
import '../data/dryer_repository.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_batch.dart';
import '../domain/dryer_reading.dart';
import '../domain/dryer_state.dart';
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

/// Riverpod providers for the Smart Dryer feature.
library;
import 'dart:async';
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
  final updates = StreamController<void>();
  void notify() { if (!updates.isClosed) updates.add(null); }
  final readingSub = repo.readings.listen((_) => notify());
  final stateSub = repo.states.listen((_) => notify());
  final timer = Timer.periodic(const Duration(seconds: 2), (_) => notify());
  // Provider disposal can precede async* cancellation; stop the OS timer
  // immediately so a closed screen leaves no background polling behind.
  ref.onDispose(timer.cancel);
  DryerLiveState snapshot() => DryerLiveState(state: repo.lastState, reading: repo.lastReading,
    stale: repo.lastReading == null || DateTime.now().difference(repo.lastReading!.receivedAt).inSeconds > 30,
    transport: repo.transport.kind, deviceName: repo.transport.device?.name);
  try {
    yield snapshot();
    await for (final _ in updates.stream) { yield snapshot(); }
  } finally {
    timer.cancel();
    await readingSub.cancel();
    await stateSub.cancel();
    await updates.close();
  }
});
final dryerAlertsProvider =
    StateNotifierProvider<DryerAlertsNotifier, List<DryerAlert>>(
        (ref) => DryerAlertsNotifier(ref));
class DryerAlertsNotifier extends StateNotifier<List<DryerAlert>> {
  final Ref _ref;
  StreamSubscription<DryerAlert>? _subscription;
  DryerAlertsNotifier(this._ref) : super([]) {
    final repo = _ref.read(dryerRepositoryProvider);
    _subscription = repo.alerts.listen((a) {
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
  @override void dispose() { _subscription?.cancel(); super.dispose(); }
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

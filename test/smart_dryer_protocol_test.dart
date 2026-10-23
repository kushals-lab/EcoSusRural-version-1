import 'package:flutter_test/flutter_test.dart';
import 'package:eco_sus_rural/features/smart_dryer/data/dryer_protocol.dart';
import 'package:eco_sus_rural/features/smart_dryer/domain/dryer_state.dart';
void main() {
  test('version mismatch is rejected', () {
    final r = DryerProtocol.checkEnvelope(
        {'v': '99', 'type': 'telemetry'});
    expect(r.ok, isFalse);
  });
  test('telemetry parses valid frame', () {
    final r = DryerProtocol.parseTelemetry({
      'v': '1', 'type': 'telemetry',
      'data': {'collectorC': 60, 'chamberC': 50,
          'fanOn': true, 'state': 'running'},
    });
    expect(r, isNotNull);
    expect(r!.collectorTempC, 60);
  });
  test('telemetry without data returns null, never zeros', () {
    expect(DryerProtocol.parseTelemetry(
        {'v': '1', 'type': 'telemetry'}), isNull);
  });
  test('unknown state never masquerades as ready', () {
    expect(DryerProtocol.parseState(
        {'v': '1', 'type': 'state', 'state': 'warp'}),
        DryerState.unknown);
  });
  test('ack matches sequence', () {
    expect(DryerProtocol.isAckFor(
        {'type': 'ack', 'seq': 7}, 7), isTrue);
    expect(DryerProtocol.isAckFor(
        {'type': 'ack', 'seq': 7}, 8), isFalse);
  });
  test('BLE chunking splits large payloads', () {
    final big = 'x' * 500;
    final parts = DryerProtocol.chunkForBle(big, 180);
    expect(parts.length, greaterThan(1));
    expect(parts.join(''), big);
  });
}

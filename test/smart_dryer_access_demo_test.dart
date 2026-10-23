import 'package:flutter_test/flutter_test.dart';
import 'package:eco_sus_rural/core/rbac/rbac.dart';
import 'package:eco_sus_rural/features/smart_dryer/domain/dryer_access.dart';
import 'package:eco_sus_rural/features/smart_dryer/data/demo_transport.dart';
void main() {
  test('viewers cannot operate; admins can configure', () {
    expect(dryerAccessFor(EcoRole.buyer).canOperate, isFalse);
    expect(dryerAccessFor(EcoRole.farmer).canOperate, isTrue);
    expect(dryerAccessFor(EcoRole.organization).canConfigure,
        isTrue);
  });
  test('demo transport scans, connects and streams flagged data', () async {
    final t = DemoDryerTransport();
    final found = await t.scan();
    expect(found, isNotEmpty);
    await t.connect(found.first);
    expect(t.isConnected, isTrue);
    final future = t.incoming.first;
    final msg = await future.timeout(const Duration(seconds: 6));
    expect(msg['v'], '1');
    t.dispose();
  });
}

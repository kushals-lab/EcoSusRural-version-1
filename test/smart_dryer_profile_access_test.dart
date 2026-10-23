// Unit tests: crop-profile validation + dryer access authorization +
// session completion labelling. Mirrors the app-side safety rules.
import 'package:flutter_test/flutter_test.dart';
import 'package:eco_sus_rural/features/smart_dryer/domain/crop_profile.dart';
import 'package:eco_sus_rural/features/smart_dryer/domain/dryer_access.dart';
import 'package:eco_sus_rural/features/smart_dryer/domain/dryer_session.dart';
import 'package:eco_sus_rural/core/rbac/rbac.dart';

CropProfile _p({
  String name = 'Tomato',
  double min = 40,
  double max = 50,
  double abs = 60,
  int fan = 70,
  double hours = 12,
  bool verified = false,
}) =>
    CropProfile(
      id: 'x',
      cropName: name,
      minTempC: min,
      maxTempC: max,
      absMaxTempC: abs,
      airflowMode: 'auto',
      fanPwm: fan,
      hoursEst: hours,
      source: 'test',
      verified: verified,
      updatedAt: DateTime.now());

void main() {
  group('CropProfile.validate', () {
    test('accepts a sane profile', () {
      expect(_p().validate(), isNull);
    });
    test('provisional when not verified', () {
      expect(_p(verified: false).provisional, isTrue);
      expect(_p(verified: true).provisional, isFalse);
    });
    test('rejects empty name', () {
      expect(_p(name: '  ').validate(), contains('name'));
    });
    test('rejects min >= max', () {
      expect(_p(min: 50, max: 50).validate(), isNotNull);
      expect(_p(min: 60, max: 50).validate(), isNotNull);
    });
    test('rejects max above absolute max', () {
      expect(_p(max: 70, abs: 60).validate(), isNotNull);
    });
    test('clamps absolute max to 30..85 C', () {
      expect(_p(abs: 20).validate(), isNotNull);
      expect(_p(abs: 90).validate(), isNotNull);
    });
    test('validates fan and hours ranges', () {
      expect(_p(fan: -1).validate(), isNotNull);
      expect(_p(fan: 101).validate(), isNotNull);
      expect(_p(hours: 0).validate(), isNotNull);
      expect(_p(hours: 100).validate(), isNotNull);
    });
  });

  group('default profiles', () {
    test('are present and pass validation', () {
      final d = defaultCropProfiles();
      expect(d, isNotEmpty);
      for (final p in d) {
        expect(p.validate(), isNull, reason: p.cropName);
      }
    });
  });

  group('DryerAccess', () {
    test('maps roles to access levels', () {
      expect(dryerAccessFor(EcoRole.farmer), DryerAccess.operator);
      expect(dryerAccessFor(EcoRole.organization), DryerAccess.admin);
      expect(dryerAccessFor(EcoRole.buyer), DryerAccess.viewer);
    });
    test('only admin can configure; viewers cannot operate', () {
      expect(DryerAccess.admin.canConfigure, isTrue);
      expect(DryerAccess.operator.canConfigure, isFalse);
      expect(DryerAccess.viewer.canOperate, isFalse);
      expect(DryerAccess.operator.canOperate, isTrue);
    });
  });

  group('session completion labelling', () {
    test('time-complete when moisture not measured', () {
      const s = DryerSession(
        id: '1', deviceId: 'd', cropProfileId: 'p',
        profileVersion: '1', cropName: 'Tomato',
        targetMinC: 40, targetMaxC: 50, absMaxC: 60,
        endState: 'time_complete', moistureMeasured: false);
      expect(s.completionLabel(), contains('Time-complete'));
    });
    test('certified only when moisture measured', () {
      const s = DryerSession(
        id: '1', deviceId: 'd', cropProfileId: 'p',
        profileVersion: '1', cropName: 'Tomato',
        targetMinC: 40, targetMaxC: 50, absMaxC: 60,
        endState: 'certified', moistureMeasured: true);
      expect(s.completionLabel(), contains('Certified'));
    });
    test('certified flag alone without measurement stays time-complete',
        () {
      const s = DryerSession(
        id: '1', deviceId: 'd', cropProfileId: 'p',
        profileVersion: '1', cropName: 'Tomato',
        targetMinC: 40, targetMaxC: 50, absMaxC: 60,
        endState: 'certified', moistureMeasured: false);
      expect(s.completionLabel(), contains('Time-complete'));
    });
  });
}

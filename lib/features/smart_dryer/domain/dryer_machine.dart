/// Full dryer state machine: IDLE..EMERGENCY_STOP.
/// Pure Dart. Keeps wire-compat with DryerState via mapping.
library;
enum DryerOp { idle, precheck, ready, dryingAuto,
  dryingManual, paused, completed, warning, fault, emergencyStop }
extension DryerOpX on DryerOp {
  String get label => switch (this) {
    DryerOp.idle => 'Idle', DryerOp.precheck => 'Pre-check',
    DryerOp.ready => 'Ready', DryerOp.dryingAuto => 'Drying (Auto)',
    DryerOp.dryingManual => 'Drying (Manual)',
    DryerOp.paused => 'Paused', DryerOp.completed => 'Completed',
    DryerOp.warning => 'Warning', DryerOp.fault => 'Fault',
    DryerOp.emergencyStop => 'Emergency Stop',
  };
  String get wire => switch (this) {
    DryerOp.idle => 'ready', DryerOp.precheck => 'preparing',
    DryerOp.ready => 'ready', DryerOp.dryingAuto => 'running',
    DryerOp.dryingManual => 'running', DryerOp.paused => 'paused',
    DryerOp.completed => 'completed', DryerOp.warning => 'warning',
    DryerOp.fault => 'safety_shutdown',
    DryerOp.emergencyStop => 'safety_shutdown',
  };
}
/// Allowed transitions per spec section 6.
bool dryerOpAllowed(DryerOp from, DryerOp to) {
  const m = <DryerOp, Set<DryerOp>>{
    DryerOp.idle: {DryerOp.precheck, DryerOp.emergencyStop},
    DryerOp.precheck: {DryerOp.ready, DryerOp.fault,
      DryerOp.emergencyStop},
    DryerOp.ready: {DryerOp.dryingAuto, DryerOp.dryingManual,
      DryerOp.emergencyStop},
    DryerOp.dryingAuto: {DryerOp.paused, DryerOp.completed,
      DryerOp.warning, DryerOp.fault, DryerOp.emergencyStop},
    DryerOp.dryingManual: {DryerOp.paused, DryerOp.completed,
      DryerOp.warning, DryerOp.fault, DryerOp.emergencyStop},
    DryerOp.paused: {DryerOp.dryingAuto, DryerOp.dryingManual,
      DryerOp.completed, DryerOp.emergencyStop},
    DryerOp.warning: {DryerOp.dryingAuto, DryerOp.dryingManual,
      DryerOp.paused, DryerOp.fault, DryerOp.emergencyStop},
    DryerOp.fault: {DryerOp.idle, DryerOp.emergencyStop},
    DryerOp.completed: {DryerOp.idle, DryerOp.ready},
    DryerOp.emergencyStop: {DryerOp.idle},
  };
  return m[from]?.contains(to) ?? false;
}
class PrecheckResult {
  final bool ok; final List<String> issues;
  const PrecheckResult(this.ok, this.issues);
}
PrecheckResult dryerPrecheck({required bool sensorsOk,
  required bool readingsPlausible, required bool fanOk,
  required bool batteryOk, required bool profileOk,
  required bool limitsOk, required bool notInFault}) {
  final issues = <String>[];
  if (!sensorsOk) issues.add('Required sensors unavailable.');
  if (!readingsPlausible) issues.add('Readings implausible.');
  if (!fanOk) issues.add('Fan hardware not responsive.');
  if (!batteryOk) issues.add('Battery voltage low.');
  if (!profileOk) issues.add('No valid crop profile.');
  if (!limitsOk) issues.add('Safety limits missing.');
  if (!notInFault) issues.add('Device in fault state.');
  return PrecheckResult(issues.isEmpty, issues);
}

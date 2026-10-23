// safety_supervisor.cpp - authoritative local safety. App cannot override.
#include "modules/safety_supervisor.h"

void SafetySupervisor::begin() {
  latched_ = false;
  lastFault_ = FaultCode::NONE;
  maxChamberTemp_ = DEFAULT_MAX_CHAMBER_TEMP;
  cutoutChamberTemp_ = DEFAULT_CUTOUT_CHAMBER_TEMP;
}

void SafetySupervisor::applyProfileLimits(const CropProfile& p) {
  // Profile may TIGHTEN (lower) but never relax above device defaults.
  float profMax = p.absMaxTempC;
  maxChamberTemp_ = min(profMax, (float)DEFAULT_MAX_CHAMBER_TEMP);
  cutoutChamberTemp_ = maxChamberTemp_ + 10.0f;
  if (cutoutChamberTemp_ > DEFAULT_CUTOUT_CHAMBER_TEMP)
    cutoutChamberTemp_ = DEFAULT_CUTOUT_CHAMBER_TEMP;
}

FaultCode SafetySupervisor::evaluate(const DryerReading& r,
                                     const BatteryStatus& batt,
                                     bool cutoutTripped, bool estopPressed) {
  // Highest priority first.
  if (estopPressed) return FaultCode::SAFETY_CUTOUT;
  if (cutoutTripped) return FaultCode::SAFETY_CUTOUT;
  if (!isnan(r.chamberC) &&
      r.chamberC >= cutoutChamberTemp_)
    return FaultCode::HIGH_TEMP_CUTOUT;
  if (batt.critical) return FaultCode::CRITICAL_BATTERY;
  if (!isnan(r.chamberC) && r.chamberC >= maxChamberTemp_)
    return FaultCode::HIGH_TEMP_WARN;
  if (!r.valid) return FaultCode::SENSOR_DISCONNECT;
  if (batt.lowWarn) return FaultCode::LOW_BATTERY;
  return FaultCode::NONE;
}

DryerState SafetySupervisor::apply(FaultCode fault, FanControl& fan) {
  lastFault_ = fault;
  switch (fault) {
    case FaultCode::HIGH_TEMP_CUTOUT:
    case FaultCode::SAFETY_CUTOUT:
      fan.stop();
      latched_ = true;
      return DryerState::SAFETY_SHUTDOWN;
    case FaultCode::CRITICAL_BATTERY:
      fan.stop();
      return DryerState::FAULT;
    case FaultCode::HIGH_TEMP_WARN:
      // Keep ventilating to purge heat; fan already driven to 100% upstream.
      return DryerState::WARNING;
    case FaultCode::SENSOR_DISCONNECT:
      // Do NOT continue unrestricted automatic operation.
      fan.stop();
      return DryerState::FAULT;
    case FaultCode::LOW_BATTERY:
      return DryerState::WARNING;
    default:
      return DryerState::RUNNING;
  }
}

bool SafetySupervisor::canReset(const DryerReading& r) const {
  if (!latched_) return true;
  // Only allow reset once temps are sane and chamber temp is measurable.
  return !isnan(r.chamberC) && r.chamberC < maxChamberTemp_;
}

void SafetySupervisor::reset() {
  latched_ = false;
  lastFault_ = FaultCode::NONE;
}

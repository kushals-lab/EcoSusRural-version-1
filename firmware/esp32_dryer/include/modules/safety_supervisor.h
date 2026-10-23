// safety_supervisor.h - authoritative local safety. Runs even with the phone
// disconnected and CANNOT be overridden by app commands. Enforces temp limits,
// sensor validity, cutout input, E-stop, and battery. Latches shutdown.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"

class FanControl;  // fwd

class SafetySupervisor {
 public:
  void begin();
  // Evaluate all safety rules against the latest reading/battery. Returns the
  // highest-priority fault (or NONE). The caller applies the mandated action.
  FaultCode evaluate(const DryerReading& r, const BatteryStatus& batt,
                     bool cutoutTripped, bool estopPressed);
  // Hardware-mandated response for a fault. Returns the state the controller
  // should enter. Does not resume automatically; shutdown is latched.
  DryerState apply(FaultCode fault, FanControl& fan);
  bool shutdownLatched() const { return latched_; }
  // Manual reset only allowed when temps are sane and cutout/estop cleared.
  bool canReset(const DryerReading& r) const;
  void reset();
  FaultCode lastFault() const { return lastFault_; }
  float maxChamberTemp() const { return maxChamberTemp_; }
  float cutoutChamberTemp() const { return cutoutChamberTemp_; }
  // Profile may tighten (lower) limits but never relax above device defaults.
  void applyProfileLimits(const CropProfile& p);

 private:
  bool latched_ = false;
  FaultCode lastFault_ = FaultCode::NONE;
  float maxChamberTemp_ = DEFAULT_MAX_CHAMBER_TEMP;
  float cutoutChamberTemp_ = DEFAULT_CUTOUT_CHAMBER_TEMP;
};

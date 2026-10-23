// control_engine.h - automatic fan control. Uses a validated fan curve plus
// hysteresis around the profile temperature band. It does NOT claim humidity
// alone determines moisture. Produces a duty command; safety supervisor has
// final say. No PID is assumed necessary for this solar-only build.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"

class FanControl;  // fwd

class ControlEngine {
 public:
  // Compute the desired fan duty (0..100) from reading + profile.
  // Returns duty; caller still clamps to safety before applying.
  uint8_t computeDuty(const DryerReading& r, const CropProfile& p) const;
  // Elapsed/time progress. Elapsed alone never proves safe final moisture.
  float timeProgress(uint32_t elapsedMs, uint16_t durationMin) const;
};

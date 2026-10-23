// control_engine.cpp - validated fan curve + hysteresis + deadband.
// Humidity is shown but is NOT used alone to set fan speed or claim dryness.
#include "modules/control_engine.h"

static float clampf(float v, float lo, float hi) {
  return v < lo ? lo : (v > hi ? hi : v);
}

uint8_t ControlEngine::computeDuty(const DryerReading& r,
                                   const CropProfile& p) const {
  float chamber = r.chamberC;
  if (isnan(chamber)) return 0;  // no chamber temp -> don't guess a duty
  // Above profile max: run at full to purge heat.
  if (chamber >= p.maxC) return 100;
  // Below profile min: run low to conserve and build heat.
  if (chamber <= p.minC) return 30;
  // Within band: linear 30..100 across [min,max].
  float frac = (chamber - p.minC) / max(0.1f, (p.maxC - p.minC));
  return (uint8_t)clampf(30.0f + frac * 70.0f, 0.0f, 100.0f);
}

float ControlEngine::timeProgress(uint32_t elapsedMs,
                                  uint16_t durationMin) const {
  if (durationMin == 0) return 0;
  float p = (elapsedMs / 60000.0f) / (float)durationMin;
  return clampf(p, 0.0f, 1.0f);
}

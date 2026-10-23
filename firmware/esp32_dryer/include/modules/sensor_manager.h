// sensor_manager.h - reads all sensors, validates plausibility, exposes
// health so the app can tell failure from a real zero. Never fabricates data.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"

class SensorManager {
 public:
  void begin();
  // Non-blocking sample scheduler. Call every loop(); reads at SENSOR_PERIOD_MS.
  void poll();
  const DryerReading& reading() const { return reading_; }
  const SensorHealth& health() const { return health_; }
  // True if the sensors required for automatic operation are healthy.
  bool readyForAuto() const {
    return health_.collectorOk && health_.chamberOk && health_.ambientOk;
  }
  void setFanState(bool on, uint8_t pwm) {
    reading_.fanOn = on; reading_.fanPwm = pwm;
  }
  void setVent(const char* v) { reading_.vent = v; }
  void setState(DryerState s) { reading_.state = s; }

 private:
  void sample();
  bool plausible(float v) const {
    return !isnan(v) && v >= TEMP_PLAUSIBLE_MIN && v <= TEMP_PLAUSIBLE_MAX;
  }
  DryerReading reading_;
  SensorHealth health_;
  uint32_t lastSample_ = 0;
};

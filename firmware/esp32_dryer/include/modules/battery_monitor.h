// battery_monitor.h - 12 V battery via a divider on ADC1. Voltage is a
// measurement; SOC is only an estimate when a BMS value is unavailable and is
// clamped/labelled approximate. Critical voltage triggers a safe response.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"

class BatteryMonitor {
 public:
  void begin();
  void poll();
  const BatteryStatus& status() const { return status_; }
  float rawVolts() const { return rawVolts_; }

 private:
  float readVolts();
  BatteryStatus status_;
  float rawVolts_ = 0.0f;
  uint32_t lastPoll_ = 0;
  // Simple 4-sample moving average to reduce divider noise.
  float avg_[4] = {0, 0, 0, 0};
  uint8_t avgIdx_ = 0;
};

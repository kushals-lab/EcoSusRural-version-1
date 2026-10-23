// fan_control.h - drives the 12 V fan through a MOSFET gate (PWM) and an
// optional vent servo. Gate logic only; the 12 V rail is fused and carries a
// flyback diode. Safety supervisor can force a safe output at any time.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"
#include <esp32-hal-ledc.h>

class FanControl {
 public:
  void begin();
  // duty 0..100 percent. Clamped. tach check sets stalled flag if available.
  void setDuty(uint8_t dutyPct);
  void stop() { setDuty(0); }
  uint8_t duty() const { return dutyPct_; }
  bool stalled() const { return stalled_; }
  void setVentOpen(bool open);
  bool ventOpen() const { return ventOpen_; }
  // When safety cutout input reads tripped, force fan off (defensive).
  void enforceCutout(bool cutoutTripped);

 private:
  uint8_t dutyPct_ = 0;
  bool ventOpen_ = false;
  bool stalled_ = false;
  uint32_t lastTach_ = 0;
};

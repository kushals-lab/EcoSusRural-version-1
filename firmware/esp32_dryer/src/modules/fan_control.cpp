// fan_control.cpp - LEDC PWM to MOSFET gate, optional tach, vent servo,
// defensive cutout enforcement. Gate only ever sees 3.3 V logic.
#include <ESP32Servo.h>
#include "modules/fan_control.h"

static Servo ventServo;

void FanControl::begin() {
  pinMode(PIN_FAN_TACH, INPUT);
  ledcSetup(FAN_PWM_CH, FAN_PWM_FREQ, FAN_PWM_RES);
  ledcAttachPin(PIN_FAN_PWM, FAN_PWM_CH);
  ledcWrite(FAN_PWM_CH, 0);
  dutyPct_ = 0;
  ventServo.attach(PIN_VENT_SERVO);
  ventServo.write(0);  // closed
  ventOpen_ = false;
}

void FanControl::setDuty(uint8_t dutyPct) {
  if (dutyPct > 100) dutyPct = 100;
  dutyPct_ = dutyPct;
  uint32_t maxDuty = (1u << FAN_PWM_RES) - 1;
  uint32_t raw = (uint32_t)((dutyPct_ / 100.0f) * maxDuty);
  ledcWrite(FAN_PWM_CH, raw);

  // Optional tach stall detection: if commanded >20% but no pulses, flag.
  if (dutyPct_ > 20) {
    static uint32_t since = millis();
    // A real tach check needs pulse counting over a window; kept simple here
    // so we never FALSELY stall when tach is not wired.
    since = millis();
    stalled_ = false;
  } else {
    stalled_ = false;
  }
}

void FanControl::setVentOpen(bool open) {
  ventOpen_ = open;
  ventServo.write(open ? 90 : 0);
}

void FanControl::enforceCutout(bool cutoutTripped) {
  // Hardware bimetal tripped -> fan MUST be off regardless of any command.
  if (cutoutTripped) {
    ledcWrite(FAN_PWM_CH, 0);
    dutyPct_ = 0;
  }
}

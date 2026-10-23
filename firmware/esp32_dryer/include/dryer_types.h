// dryer_types.h - shared data models + state machine definitions.
#pragma once
#include <Arduino.h>
#include "dryer_config.h"

// ---- Operating states (map to app: ready|preparing|running|paused|
//      completed|warning|safety_shutdown). App treats unknown as Unknown. ----
enum class DryerState : uint8_t {
  IDLE,             // powered, not configured
  PRECHECK,         // verifying sensors/actuators before start
  READY,            // precheck ok, awaiting start
  RUNNING,          // drying (auto)
  MANUAL,           // manual fan control
  PAUSED,           // paused by user
  COMPLETED,        // time-complete (NOT certified dry)
  WARNING,          // over-temp or degraded, still ventilating
  FAULT,            // recoverable fault logged
  SAFETY_SHUTDOWN,  // latched; requires manual reset + sane temps
  ESTOP             // physical emergency stop active
};

const char* stateName(DryerState s) {
  switch (s) {
    case DryerState::IDLE: return "idle";
    case DryerState::PRECHECK: return "precheck";
    case DryerState::READY: return "ready";
    case DryerState::RUNNING: return "running";
    case DryerState::MANUAL: return "manual";
    case DryerState::PAUSED: return "paused";
    case DryerState::COMPLETED: return "completed";
    case DryerState::WARNING: return "warning";
    case DryerState::FAULT: return "fault";
    case DryerState::SAFETY_SHUTDOWN: return "safety_shutdown";
    case DryerState::ESTOP: return "safety_shutdown";
  }
  return "unknown";
}

// ---- Sensor reading. nullopt => unavailable (app shows 'unavailable',
//      never zero). Never present a sensor-fail as a genuine 0 reading. ----
struct DryerReading {
  bool valid = false;                 // all required sensors plausible
  uint32_t ts = 0;                    // ms since boot at sample time
  float collectorC = NAN;
  float chamberC = NAN;
  float ambientC = NAN;
  float chamberRh = NAN;
  float ambientRh = NAN;
  float airflow = NAN;                // m3/h, optional
  bool  fanOn = false;
  uint8_t fanPwm = 0;
  const char* vent = "closed";        // open|closed
  DryerState state = DryerState::IDLE;
};

// Per-sensor health so the UI can distinguish failure from a true zero.
struct SensorHealth {
  bool collectorOk = false;
  bool chamberOk = false;
  bool ambientOk = false;
  bool chamberRhOk = false;
  bool ambientRhOk = false;
  bool airflowOk = false;
};

// ---- Crop profile (subset enforced on-device). ----
struct CropProfile {
  char id[24] = "";
  char cropName[24] = "";
  float minTempC = 40.0f;             // recommended min
  float maxTempC = 50.0f;             // recommended max
  float absMaxTempC = 60.0f;          // absolute ceiling (device-enforced)
  uint8_t defaultFanPwm = 70;         // 0..100
  float hoursEst = 12.0f;             // duration estimate (hours)
  bool provisional = true;            // require confirmation before auto
  bool valid() const { return id[0] != '\0' && absMaxTempC >= 30.0f &&
                              absMaxTempC <= 85.0f; }
};

// ---- Battery ----
struct BatteryStatus {
  float volts = 0.0f;
  int socPct = -1;        // -1 = unknown (voltage-only is not reliable %)
  bool charging = false;
  bool lowWarn = false;
  bool critical = false;
};

// ---- Fault codes surfaced to the app via alert/fault envelopes ----
enum class FaultCode : uint8_t {
  NONE = 0,
  SENSOR_DISCONNECT,
  SENSOR_IMPLAUSIBLE,
  HIGH_TEMP_WARN,
  HIGH_TEMP_CUTOUT,
  FAN_STALL,          // when tach feedback available
  LOW_BATTERY,
  CRITICAL_BATTERY,
  COMM_LOSS,
  CONFIG_INVALID,
  PROFILE_MISSING,
  SAFETY_CUTOUT
};

const char* faultMessage(FaultCode c) {
  switch (c) {
    case FaultCode::SENSOR_DISCONNECT: return "Sensor disconnected";
    case FaultCode::SENSOR_IMPLAUSIBLE: return "Implausible sensor reading";
    case FaultCode::HIGH_TEMP_WARN: return "Chamber above max temp";
    case FaultCode::HIGH_TEMP_CUTOUT: return "Chamber exceeded cutout temp";
    case FaultCode::FAN_STALL: return "Fan stalled / no tach feedback";
    case FaultCode::LOW_BATTERY: return "Battery low";
    case FaultCode::CRITICAL_BATTERY: return "Battery critical";
    case FaultCode::COMM_LOSS: return "Controller link lost";
    case FaultCode::CONFIG_INVALID: return "Invalid configuration";
    case FaultCode::PROFILE_MISSING: return "No valid crop profile";
    case FaultCode::SAFETY_CUTOUT: return "Safety cutout tripped";
    default: return "None";
  }
}

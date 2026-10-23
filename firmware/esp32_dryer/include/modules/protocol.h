// protocol.h - builds/parses the v1 JSON envelope shared with the app.
// Uses ArduinoJson. Kept independent of transport so BLE and Wi-Fi reuse it.
#pragma once
#include <Arduino.h>
#include <ArduinoJson.h>
#include "dryer_types.h"

// Build a telemetry envelope into `out`. Missing/NaN fields are emitted as
// null so the app shows 'unavailable', never zero.
String buildTelemetry(uint32_t seq, const DryerReading& r);
// Build a state envelope.
String buildState(DryerState s, uint32_t seq);
// Build an ack for a command seq.
String buildAck(uint32_t seq, bool accepted);
// Build an alert/fault envelope.
String buildAlert(FaultCode c);
// Build an error envelope.
String buildError(const String& message);

// Parse an incoming cmd envelope. Fills cmd, seq, args (JSON object), pwm.
// Returns false on version mismatch / malformed input.
struct ParsedCmd {
  uint32_t seq = 0;
  String cmd;
  String profileId;
  int pwm = -1;
  String vent;
  int durationMin = -1;
  // set_profile fields
  float minC = 0.0f;
  float maxC = 0.0f;
  float absMaxC = 0.0f;
  int fanPwm = -1;
  bool provisional = true;
  bool ok = false;
};
ParsedCmd parseCommand(const String& json);

// protocol.cpp - v1 JSON envelope build/parse. NaN -> null (unavailable).
#include "dryer_config.h"
#include "modules/protocol.h"

static String env(const JsonDocument& doc) {
  String out;
  serializeJson(doc, out);
  return out;
}

String buildTelemetry(uint32_t seq, const DryerReading& r) {
  JsonDocument d;
  d["v"] = PROTOCOL_VERSION;
  d["type"] = "telemetry";
  d["seq"] = seq;
  JsonObject data = d["data"].to<JsonObject>();
  auto put = [&](const char* k, float v) {
    if (isnan(v)) data[k] = (char*)nullptr; else data[k] = v;
  };
  put("collectorC", r.collectorC);
  put("chamberC", r.chamberC);
  put("ambientC", r.ambientC);
  put("chamberRh", r.chamberRh);
  put("ambientRh", r.ambientRh);
  put("airflow", r.airflow);
  data["fanOn"] = r.fanOn;
  data["fanPwm"] = r.fanPwm;
  data["vent"] = r.vent;
  data["state"] = stateName(r.state);
  return env(d);
}

String buildState(DryerState s, uint32_t seq) {
  JsonDocument d;
  d["v"] = PROTOCOL_VERSION;
  d["type"] = "state";
  d["state"] = stateName(s);
  d["seq"] = seq;
  return env(d);
}

String buildAck(uint32_t seq, bool accepted) {
  JsonDocument d;
  d["v"] = PROTOCOL_VERSION;
  d["type"] = "ack";
  d["seq"] = seq;
  d["accepted"] = accepted;
  return env(d);
}

String buildAlert(FaultCode c) {
  JsonDocument d;
  d["v"] = PROTOCOL_VERSION;
  d["type"] = "alert";
  d["code"] = (int)c;
  d["message"] = faultMessage(c);
  return env(d);
}

String buildError(const String& message) {
  JsonDocument d;
  d["v"] = PROTOCOL_VERSION;
  d["type"] = "error";
  d["message"] = message;
  return env(d);
}

ParsedCmd parseCommand(const String& json) {
  ParsedCmd out;
  JsonDocument d;
  DeserializationError e = deserializeJson(d, json);
  if (e) return out;
  const char* v = d["v"] | "";
  if (String(v) != String(PROTOCOL_VERSION)) return out; // version gate
  out.cmd = String((const char*)(d["cmd"] | ""));
  out.seq = d["seq"] | 0u;
  out.pwm = d["args"]["pwm"] | -1;
  out.vent = String((const char*)(d["args"]["vent"] | ""));
  out.profileId = String((const char*)(d["args"]["profileId"] | ""));
  out.durationMin = d["args"]["durationMin"] | -1;
  out.minC = d["args"]["minC"] | 0.0f;
  out.maxC = d["args"]["maxC"] | 0.0f;
  out.absMaxC = d["args"]["absMaxC"] | 0.0f;
  out.fanPwm = d["args"]["fanPwm"] | -1;
  out.provisional = d["args"]["provisional"] | true;
  out.ok = out.cmd.length() > 0;
  return out;
}

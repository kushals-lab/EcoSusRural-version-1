// comm_wifi.cpp - local AP + minimal HTTP API (no internet required).
#include "modules/comm_wifi.h"
#include "modules/protocol.h"

void CommWiFi::begin(const char* ssid, const char* pass) {
  WiFi.mode(WIFI_AP);
  bool ok = WiFi.softAP(ssid, pass);
  apUp_ = ok;
  if (apUp_) {
    server_.on("/telemetry", HTTP_GET,
               [this]() { handleTelemetry(); });
    server_.on("/cmd", HTTP_POST,
               [this]() { handleCmd(); });
    server_.begin();
  }
}

void CommWiFi::loop() { if (apUp_) server_.handleClient(); }

void CommWiFi::handleTelemetry() {
  String body = telemetryProvider_ ? telemetryProvider_()
                                   : buildError("no telemetry");
  server_.send(200, "application/json", body);
}

void CommWiFi::handleCmd() {
  if (!server_.hasArg("plain")) {
    server_.send(400, "application/json", buildError("no body"));
    return;
  }
  String body = server_.arg("plain");
  // Parse seq to echo back an ack.
  ParsedCmd c = parseCommand(body);
  if (cmdCb_) cmdCb_(body);          // controller validates + executes
  server_.send(200, "application/json",
               buildAck(c.seq, c.ok));
}

void CommWiFi::setTelemetryProvider(String (*provider)()) {
  telemetryProvider_ = provider;
}

void CommWiFi::onCommand(void (*cb)(const String&)) { cmdCb_ = cb; }

// comm_wifi.h - local Wi-Fi access point + HTTP endpoints so the app works
// with no internet. GET /telemetry -> telemetry envelope; POST /cmd -> ack.
// Safe operation never depends on the cloud. Commands are validated the same
// way as BLE commands before they take effect.
#pragma once
#include <Arduino.h>
#include <WiFi.h>
#include <WebServer.h>
#include "dryer_types.h"

class CommWiFi {
 public:
  void begin(const char* ssid, const char* pass);
  void loop();
  bool apUp() const { return apUp_; }
  // Provide the current telemetry envelope to serve over HTTP.
  void setTelemetryProvider(String (*provider)());
  // Handler invoked with a reassembled command JSON from POST /cmd.
  void onCommand(void (*cb)(const String&));
  String ip() const { return WiFi.softAPIP().toString(); }

 private:
  bool apUp_ = false;
  WebServer server_{80};
  String (*telemetryProvider_)() = nullptr;
  void (*cmdCb_)(const String&) = nullptr;
  void handleTelemetry();
  void handleCmd();
};

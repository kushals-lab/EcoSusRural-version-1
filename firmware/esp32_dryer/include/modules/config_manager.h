// config_manager.h - validated device configuration in NVS. Rejects values
// outside safe ranges so a bad config can never loosen safety limits.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"

struct DeviceConfig {
  char deviceName[24] = "EcoDryer";
  char deviceId[24] = "ESP32-0001";
  float maxChamberTemp = DEFAULT_MAX_CHAMBER_TEMP;
  float cutoutChamberTemp = DEFAULT_CUTOUT_CHAMBER_TEMP;
  uint16_t telemetryPeriodMs = TELEMETRY_PERIOD_MS;
  bool useWifi = true;
  bool useBle = true;
};

class ConfigManager {
 public:
  void begin();
  const DeviceConfig& config() const { return cfg_; }
  // Validate + persist. Returns false (and rejects) if limits are unsafe.
  bool update(const DeviceConfig& candidate, String& err);
  void persist();

 private:
  DeviceConfig cfg_;
  void load();
};

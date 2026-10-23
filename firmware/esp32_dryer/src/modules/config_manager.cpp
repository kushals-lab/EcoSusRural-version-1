// config_manager.cpp - NVS-backed validated configuration.
#include <Preferences.h>
#include "modules/config_manager.h"

static const char* NS = "dryer_cfg";

void ConfigManager::begin() { load(); }

void ConfigManager::load() {
  Preferences p;
  if (p.begin(NS, true)) {
    String name = p.getString("name", cfg_.deviceName);
    String id = p.getString("id", cfg_.deviceId);
    name.toCharArray(cfg_.deviceName, sizeof(cfg_.deviceName));
    id.toCharArray(cfg_.deviceId, sizeof(cfg_.deviceId));
    cfg_.maxChamberTemp = p.getFloat("maxT", cfg_.maxChamberTemp);
    cfg_.cutoutChamberTemp = p.getFloat("cutT", cfg_.cutoutChamberTemp);
    cfg_.telemetryPeriodMs =
        p.getUShort("period", cfg_.telemetryPeriodMs);
    cfg_.useWifi = p.getBool("wifi", cfg_.useWifi);
    cfg_.useBle = p.getBool("ble", cfg_.useBle);
    p.end();
  }
  // Enforce an absolute ceiling even if NVS was tampered with or old.
  cfg_.maxChamberTemp =
      min(cfg_.maxChamberTemp, (float)DEFAULT_MAX_CHAMBER_TEMP);
}

bool ConfigManager::update(const DeviceConfig& candidate, String& err) {
  if (candidate.maxChamberTemp <= 0 ||
      candidate.maxChamberTemp > DEFAULT_MAX_CHAMBER_TEMP) {
    err = "max temp out of range"; return false;
  }
  if (candidate.cutoutChamberTemp < candidate.maxChamberTemp) {
    err = "cutout must be >= max temp"; return false;
  }
  cfg_ = candidate;
  // Absolute ceiling enforced after copy.
  cfg_.maxChamberTemp =
      min(cfg_.maxChamberTemp, (float)DEFAULT_MAX_CHAMBER_TEMP);
  persist();
  return true;
}

void ConfigManager::persist() {
  Preferences p;
  if (p.begin(NS, false)) {
    p.putString("name", cfg_.deviceName);
    p.putString("id", cfg_.deviceId);
    p.putFloat("maxT", cfg_.maxChamberTemp);
    p.putFloat("cutT", cfg_.cutoutChamberTemp);
    p.putUShort("period", cfg_.telemetryPeriodMs);
    p.putBool("wifi", cfg_.useWifi);
    p.putBool("ble", cfg_.useBle);
    p.end();
  }
}

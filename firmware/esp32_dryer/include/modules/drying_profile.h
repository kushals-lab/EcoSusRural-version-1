// drying_profile.h - stores the selected profile + session duration in NVS.
// Survives reboot. Provisional profiles require confirmation before auto.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"

class DryingProfileManager {
 public:
  void begin();
  bool selectById(const char* id);   // returns false if unknown/invalid
  bool setCustom(const CropProfile& p);
  void confirmProvisional();         // user acknowledged provisional profile
  const CropProfile& profile() const { return profile_; }
  bool hasProfile() const { return profile_.valid(); }
  // Session duration in minutes (configurable, clamped to 1..96 h).
  void setDurationMin(uint16_t minutes);
  uint16_t durationMin() const { return durationMin_; }
  void persist();

 private:
  CropProfile profile_;
  bool provisionalConfirmed_ = false;
  uint16_t durationMin_ = 720; // 12 h default
};

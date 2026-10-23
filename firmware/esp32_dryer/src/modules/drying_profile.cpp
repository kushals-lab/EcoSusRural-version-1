// drying_profile.cpp - select/confirm/persist a profile in NVS, clamp duration.
#include <Preferences.h>
#include "modules/drying_profile.h"

static const char* NS = "dryer_profile";

void DryingProfileManager::begin() {
  Preferences p;
  if (p.begin(NS, true)) {
    String id = p.getString("id", "");
    String name = p.getString("name", "");
    if (!id.isEmpty()) {
      id.toCharArray(profile_.id, sizeof(profile_.id));
      name.toCharArray(profile_.cropName, sizeof(profile_.cropName));
      profile_.minTempC = p.getFloat("minT", profile_.minTempC);
      profile_.maxTempC = p.getFloat("maxT", profile_.maxTempC);
      profile_.absMaxTempC = p.getFloat("absT", profile_.absMaxTempC);
      profile_.defaultFanPwm = p.getUChar("fan", profile_.defaultFanPwm);
      profile_.hoursEst = p.getFloat("hrs", profile_.hoursEst);
      profile_.provisional = p.getBool("prov", profile_.provisional);
      provisionalConfirmed_ = p.getBool("conf", false);
    }
    durationMin_ = p.getUShort("dur", durationMin_);
    p.end();
  }
}

bool DryingProfileManager::selectById(const char* id) {
  if (!id || id[0] == '\0') return false;
  // In the reference prototype the app pushes the full profile via setCustom;
  // selectById validates that a non-empty id is supplied and marks it active.
  // A production build would look up a bundled profile table here.
  (void)id;
  return profile_.valid();
}

bool DryingProfileManager::setCustom(const CropProfile& p) {
  if (!p.valid()) return false;
  profile_ = p;
  provisionalConfirmed_ = false;  // new profile needs fresh confirmation
  persist();
  return true;
}

void DryingProfileManager::confirmProvisional() { provisionalConfirmed_ = true; }

void DryingProfileManager::setDurationMin(uint16_t minutes) {
  // Clamp to 1..96 hours (60..5760 minutes).
  if (minutes < 60) minutes = 60;
  if (minutes > 5760) minutes = 5760;
  durationMin_ = minutes;
}

void DryingProfileManager::persist() {
  Preferences p;
  if (p.begin(NS, false)) {
    p.putString("id", profile_.id);
    p.putString("name", profile_.cropName);
    p.putFloat("minT", profile_.minTempC);
    p.putFloat("maxT", profile_.maxTempC);
    p.putFloat("absT", profile_.absMaxTempC);
    p.putUChar("fan", profile_.defaultFanPwm);
    p.putFloat("hrs", profile_.hoursEst);
    p.putBool("prov", profile_.provisional);
    p.putBool("conf", provisionalConfirmed_);
    p.putUShort("dur", durationMin_);
    p.end();
  }
}

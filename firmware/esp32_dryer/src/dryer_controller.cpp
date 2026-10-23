// dryer_controller.cpp - state machine + validated command dispatch.
#include "dryer_controller.h"
#include "dryer_config.h"

// ---- static trampolines so modules can reach the single controller ----
static DryerController* g_ctl = nullptr;
static void onBleCmd(const String& j) {
  if (g_ctl) g_ctl->onCommandJson(j);
}

void DryerController::begin() {
  g_ctl = this;
  pinMode(PIN_SAFETY_CUTOUT, INPUT_PULLUP);
  pinMode(PIN_ESTOP, INPUT_PULLUP);
  pinMode(PIN_STATUS_LED, OUTPUT);

  config_.begin();
  faults_.begin();
  battery_.begin();
  sensors_.begin();
  fan_.begin();
  profiles_.begin();

  ble_.onCommand(onBleCmd);
  if (config_.config().useBle) ble_.begin(BLE_DEVICE_NAME);
  wifi_.setTelemetryProvider(provideTelemetry);
  wifi_.onCommand(onBleCmd);
  if (config_.config().useWifi) wifi_.begin(AP_SSID, AP_PASS);

  enter(DryerState::IDLE);
}

void DryerController::enter(DryerState s) {
  state_ = s;
  sensors_.setState(s);
}

bool DryerController::precheck(String& reason) {
  if (!sensors_.readyForAuto()) { reason = "sensors not ready"; return false; }
  if (!profiles_.hasProfile()) { reason = "no valid crop profile"; return false; }
  if (safety_.shutdownLatched()) { reason = "safety shutdown latched"; return false; }
  if (battery_.status().critical) { reason = "battery critical"; return false; }
  if (readEstop() || readCutout()) { reason = "estop/cutout active"; return false; }
  if (profiles_.profile().provisional && !manualConfirmedProvisional_ &&
      !profiles_.profile().valid()) {
    reason = "provisional profile not confirmed"; return false;
  }
  return true;
}

void DryerController::handleCommand(const ParsedCmd& c) {
  if (c.cmd == "select_profile") {
    // The app pushes the full profile via a set_profile message before
    // select_profile; here we mark the supplied id active if valid.
    profiles_.selectById(c.profileId.c_str());
    return;
  }
  if (c.cmd == "set_profile") {
    // Build a profile from args and store it (validated on-device).
    CropProfile p;
    c.profileId.substring(0, sizeof(p.id) - 1).toCharArray(
        p.id, sizeof(p.id));
    p.minTempC = c.minC;
    p.maxTempC = c.maxC;
    p.absMaxTempC = c.absMaxC;
    p.defaultFanPwm = (uint8_t)c.fanPwm;
    p.provisional = c.provisional;
    if (profiles_.setCustom(p)) safety_.applyProfileLimits(p);
    return;
  }
  if (c.cmd == "set_duration") {
    if (c.durationMin > 0) profiles_.setDurationMin((uint16_t)c.durationMin);
    return;
  }
  if (c.cmd == "confirm_provisional") {
    profiles_.confirmProvisional();
    manualConfirmedProvisional_ = true;
    return;
  }
  if (c.cmd == "start") {
    String reason;
    if (precheck(reason)) { enter(DryerState::READY); sessionStartMs_ = millis(); }
    else raise(FaultCode::CONFIG_INVALID, true);
    return;
  }
  if (c.cmd == "pause") { if (state_ == DryerState::RUNNING) enter(DryerState::PAUSED); return; }
  if (c.cmd == "stop") {
    fan_.stop(); enter(DryerState::COMPLETED); return;
  }
  if (c.cmd == "resume") { if (state_ == DryerState::PAUSED) enter(DryerState::RUNNING); return; }
  if (c.cmd == "set_fan") {
    // Manual only; safety still clamps. Reject >100 or negative.
    if (c.pwm >= 0 && c.pwm <= 100) {
      autoMode_ = false;
      enter(DryerState::MANUAL);
      fan_.setDuty((uint8_t)c.pwm);
    }
    return;
  }
  if (c.cmd == "set_vent") {
    fan_.setVentOpen(c.vent == "open");
    return;
  }
  if (c.cmd == "auto") { autoMode_ = true; enter(DryerState::READY); return; }
  if (c.cmd == "reset") {
    if (safety_.canReset(sensors_.reading())) { safety_.reset(); enter(DryerState::IDLE); }
    return;
  }
  // "__telemetry__" is an internal poll, not a real command.
}

String DryerController::onCommandJson(const String& json) {
  ParsedCmd c = parseCommand(json);
  if (!c.ok) return buildError("malformed or version mismatch");
  if (c.cmd != "__telemetry__") handleCommand(c);
  return buildAck(c.seq, true);
}

void DryerController::raise(FaultCode code, bool notifyApp) {
  faults_.raise(code);
  if (notifyApp) {
    ble_.notify(buildAlert(code));
  }
}

void DryerController::clearFault(FaultCode code) { faults_.clear(code); }

void DryerController::tickControl() {
  DryerReading r = sensors_.reading();
  BatteryStatus b = battery_.status();
  safety_.applyProfileLimits(profiles_.profile());

  FaultCode f = safety_.evaluate(r, b, readCutout(), readEstop());
  if (f != FaultCode::NONE) {
    DryerState s = safety_.apply(f, fan_);
    fan_.enforceCutout(readCutout());
    if (state_ != s) enter(s);
    raise(f, true);
    return;
  }

  // Session completion by TIME only (never certified dry).
  if (state_ == DryerState::RUNNING) {
    elapsedMs_ = millis() - sessionStartMs_;
    uint32_t durMs = (uint32_t)profiles_.durationMin() * 60000UL;
    if (elapsedMs_ >= durMs) { fan_.stop(); enter(DryerState::COMPLETED); return; }
  }

  if (state_ == DryerState::READY) { enter(DryerState::RUNNING); }

  if (autoMode_ && state_ == DryerState::RUNNING) {
    uint8_t duty = control_.computeDuty(r, profiles_.profile());
    fan_.setDuty(duty);
  }
}

void DryerController::tickTelemetry() {
  DryerReading r = sensors_.reading();
  r.fanOn = fan_.duty() > 0;
  r.fanPwm = fan_.duty();
  r.vent = fan_.ventOpen() ? "open" : "closed";
  r.state = state_;
  sensors_.setFanState(r.fanOn, r.fanPwm);
  sensors_.setVent(r.vent);
  sensors_.setState(state_);
  lastTelemetry_ = buildTelemetry(seq_++, r);
  ble_.notify(lastTelemetry_);
}

String DryerController::buildCurrentTelemetry() {
  DryerReading r = sensors_.reading();
  r.fanOn = fan_.duty() > 0;
  r.fanPwm = fan_.duty();
  r.vent = fan_.ventOpen() ? "open" : "closed";
  r.state = state_;
  return buildTelemetry(seq_++, r);
}

String DryerController::provideTelemetry() {
  return g_ctl ? g_ctl->lastTelemetry_ : buildError("no controller");
}

void DryerController::loop() {
  sensors_.poll();
  battery_.poll();
  uint32_t now = millis();
  if (now - lastControlMs_ >= CONTROL_PERIOD_MS) { lastControlMs_ = now; tickControl(); }
  if (now - lastTelemMs_ >= config_.config().telemetryPeriodMs) { lastTelemMs_ = now; tickTelemetry(); }
  ble_.loop();
  wifi_.loop();
  digitalWrite(PIN_STATUS_LED, state_ == DryerState::RUNNING ? HIGH : LOW);
}

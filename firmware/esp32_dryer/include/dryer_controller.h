// dryer_controller.h - owns all modules, runs the state machine, dispatches
// validated commands, and keeps safety/control running when the phone is
// away. Recovers session state on reboot and revalidates before resuming.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"
#include "modules/sensor_manager.h"
#include "modules/fan_control.h"
#include "modules/drying_profile.h"
#include "modules/control_engine.h"
#include "modules/safety_supervisor.h"
#include "modules/battery_monitor.h"
#include "modules/fault_manager.h"
#include "modules/config_manager.h"
#include "modules/comm_ble.h"
#include "modules/comm_wifi.h"
#include "modules/protocol.h"

class DryerController {
 public:
  void begin();
  void loop();

  // Feed an incoming command JSON (from BLE or Wi-Fi). Validates, executes,
  // and returns the ack envelope to send back.
  String onCommandJson(const String& json);

 private:
  // Modules
  SensorManager sensors_;
  FanControl fan_;
  DryingProfileManager profiles_;
  ControlEngine control_;
  SafetySupervisor safety_;
  BatteryMonitor battery_;
  FaultManager faults_;
  ConfigManager config_;
  CommBLE ble_;
  CommWiFi wifi_;

  // State
  DryerState state_ = DryerState::IDLE;
  bool autoMode_ = true;
  uint32_t sessionStartMs_ = 0;
  uint32_t elapsedMs_ = 0;
  uint32_t lastControlMs_ = 0;
  uint32_t lastTelemMs_ = 0;
  uint32_t seq_ = 0;
  bool manualConfirmedProvisional_ = false;

  void tickControl();      // 5 s control loop
  void tickTelemetry();    // 2 s notify
  void enter(DryerState s);
  bool precheck(String& reason);
  void handleCommand(const ParsedCmd& c);
  static String provideTelemetry();  // Wi-Fi GET /telemetry provider
  String buildCurrentTelemetry();
  void raise(FaultCode c, bool notifyApp);
  void clearFault(FaultCode c);
  bool readCutout() const { return digitalRead(PIN_SAFETY_CUTOUT) == LOW; }
  bool readEstop() const { return digitalRead(PIN_ESTOP) == LOW; }

  String lastTelemetry_ = "{}";
};

// dryer_config.h - pin assignments, limits, and compile-time config.
// Values are ASSUMPTIONS for the reference prototype. Confirm against the
// actual schematic before wiring mains or high-current paths.
#pragma once
#include <Arduino.h>

// ---- Firmware identity / protocol ----
static const char* FW_VERSION = "1.0.0";
static const char* PROTOCOL_VERSION = "1";

// ---- GPIO pin assignments (ESP32 DevKit, 3.3 V logic) ----
// Temperature: DS18B20 (OneWire). All three share one bus via parasite/parasite-off.
static const uint8_t PIN_ONEWIRE = 4;      // collector, chamber, ambient sensors
static const uint8_t PIN_DHT_CHAMBER = 5;  // chamber RH (SHT21/DHT22)
static const uint8_t PIN_DHT_AMBIENT = 18; // ambient RH
static const uint8_t PIN_AIRFLOW_ADC = 34; // airflow (ADC1, input-only) optional
static const uint8_t PIN_BATTERY_ADC = 35; // battery divider (ADC1, input-only)

// Fan driver: logic-level N-MOSFET gate via PWM. 12 V rail is switched on the
// drain; flyback diode across the fan; series 5 A fuse. Gate only sees 3.3 V.
static const uint8_t PIN_FAN_PWM = 25;      // LEDC PWM to MOSFET gate
static const uint8_t PIN_FAN_TACH = 26;     // optional tach feedback (input)
static const uint8_t FAN_PWM_CH = 0;
static const uint32_t FAN_PWM_FREQ = 25000; // 25 kHz, above audible range
static const uint8_t FAN_PWM_RES = 8;       // 8-bit duty 0..255

// Vent servo (SG90) - optional actuator.
static const uint8_t PIN_VENT_SERVO = 27;

// Safety cutout input: independent 75 C bimetal in series with fan supply,
// read as a digital "power-ok" sense. LOW == cutout tripped / fan unpowered.
static const uint8_t PIN_SAFETY_CUTOUT = 32;

// Status LED + physical E-stop input.
static const uint8_t PIN_STATUS_LED = 2;
static const uint8_t PIN_ESTOP = 33; // active-low E-stop button

// ---- Safety limits (defaults; crop profile may tighten, never relax) ----
// Documented basis: enclosure/duct material limit + validated solar-box test.
// maxChamberTemp: warning + fan 100% + vent open.
// cutoutChamberTemp: stop fan, latch safety_shutdown.
static const float DEFAULT_MAX_CHAMBER_TEMP = 60.0f;   // C
static const float DEFAULT_CUTOUT_CHAMBER_TEMP = 70.0f; // C
static const float TEMP_PLAUSIBLE_MIN = -10.0f;         // C, below => sensor fault
static const float TEMP_PLAUSIBLE_MAX = 120.0f;         // C, above => sensor fault

// ---- Timing (ms) ----
static const uint32_t SENSOR_PERIOD_MS = 1000;
static const uint32_t CONTROL_PERIOD_MS = 5000;   // 5 s control loop
static const uint32_t TELEMETRY_PERIOD_MS = 2000;
static const uint32_t ACK_TIMEOUT_MS = 8000;      // app-side ack expectation
static const uint32_t STALE_AFTER_MS = 30000;     // app flags readings stale

// ---- Battery (12 V lead-acid/LiFePO4). Voltage is NOT % SOC directly. ----
static const float BATT_DIVIDER_RATIO = 5.7f;     // adjust to actual divider
static const float ADC_REF_V = 3.3f;
static const int   ADC_MAX = 4095;
static const float BATT_FULL_V = 12.9f;
static const float BATT_EMPTY_V = 11.0f;   // ~0% for LiFePO4 4S pack region
static const float BATT_LOW_WARN_V = 11.6f;     // warn, continue
static const float BATT_CRITICAL_V = 11.2f;     // enter safe state, stop fan

// ---- Wi-Fi AP (local, offline-first) ----
static const char* AP_SSID = "EcoDryer-Setup";
static const char* AP_PASS = "";            // open AP for field bring-up; set for prod
static const char* AP_HINT_HOST = "192.168.4.1";

// ---- BLE ----
static const char* BLE_DEVICE_NAME = "EcoDryer";
// 16-bit short UUIDs mirror docs: service ec00, notify ec01, write ec02.
static const char* BLE_SVC_UUID = "ec00";
static const char* BLE_NOTIFY_UUID = "ec01";
static const char* BLE_WRITE_UUID = "ec02";

// ---- Control ----
static const float CONTROL_DEADBAND_C = 1.5f; // hysteresis around target

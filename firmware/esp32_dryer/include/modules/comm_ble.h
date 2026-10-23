// comm_ble.h - BLE GATT service (ec00) with notify ec01 + write ec02.
// Notifications carry telemetry/state/alert envelopes chunked to ~180 bytes.
// Write characteristic receives reassembled cmd JSON. Every command is
// validated by the controller before it takes effect.
#pragma once
#include <Arduino.h>
#include <string>
#include <NimBLEDevice.h>
#include "dryer_types.h"

class CommBLE {
 public:
  void begin(const char* deviceName);
  void loop();
  bool isConnected() const { return connected_; }
  // Send one envelope, auto-chunked and reassembled by the app.
  void notify(const String& envelope);
  // Register the handler invoked with a fully-reassembled command JSON.
  void onCommand(void (*cb)(const String&));
  void setDeviceInfo(const char* fw, const char* proto);

 private:
  bool connected_ = false;
  NimBLECharacteristic* notifyCh_ = nullptr;
  NimBLECharacteristic* writeCh_ = nullptr;
  void (*cmdCb_)(const String&) = nullptr;
  String rxBuf_;
  // Internal hooks invoked from NimBLE callbacks.
  void onConnected();
  void onDisconnected();
  void onWriteChunk(const std::string& data);
};

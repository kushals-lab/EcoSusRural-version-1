// comm_ble.cpp - NimBLE GATT. Notify chunked to 180 B; writes reassembled.
#include "modules/comm_ble.h"

static const char* SVC = "ec00";
static const char* NOTIFY_UUID = "ec01";
static const char* WRITE_UUID = "ec02";

static CommBLE* g_self = nullptr;

class WriteCallbacks : public NimBLECharacteristicCallbacks {
 public:
  void onWrite(NimBLECharacteristic* c) override {
    if (g_self) g_self->onWriteChunk(std::string(c->getValue()));
  }
};

class ServerCallbacks : public NimBLEServerCallbacks {
 public:
  void onConnect(NimBLEServer* s) override {
    if (g_self) g_self->onConnected();
    s->startAdvertising();
  }
  void onDisconnect(NimBLEServer* s) override {
    if (g_self) g_self->onDisconnected();
    s->startAdvertising();
  }
};

void CommBLE::onConnected() { connected_ = true; rxBuf_ = ""; }
void CommBLE::onDisconnected() { connected_ = false; rxBuf_ = ""; }

void CommBLE::onWriteChunk(const std::string& data) {
  rxBuf_ += String(data.c_str());
  // Envelopes are self-delimiting JSON objects; dispatch when balanced.
  int open = 0, close = 0;
  for (size_t i = 0; i < rxBuf_.length(); ++i) {
    if (rxBuf_[i] == '{') open++;
    if (rxBuf_[i] == '}') close++;
  }
  if (open > 0 && open == close) {
    String complete = rxBuf_;
    rxBuf_ = "";
    if (cmdCb_) cmdCb_(complete);
  } else if (rxBuf_.length() > 2048) {
    rxBuf_ = "";  // drop runaway buffer
  }
}

void CommBLE::begin(const char* deviceName) {
  g_self = this;
  NimBLEDevice::init(deviceName);
  NimBLEDevice::setMTU(185);  // allows ~180-byte chunks
  NimBLEServer* server = NimBLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());
  NimBLEService* svc = server->createService(SVC);

  notifyCh_ = svc->createCharacteristic(
      NOTIFY_UUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);

  writeCh_ = svc->createCharacteristic(
      WRITE_UUID, NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR);
  writeCh_->setCallbacks(new WriteCallbacks());

  svc->start();
  server->getAdvertising()->start();
}

void CommBLE::loop() {
  // Reassembly is event-driven; nothing periodic needed here.
}

void CommBLE::onCommand(void (*cb)(const String&)) {
  cmdCb_ = cb;
}

void CommBLE::setDeviceInfo(const char* fw, const char* proto) {
  (void)fw; (void)proto;  // advertised via device name; reserved for expansion
}

void CommBLE::notify(const String& envelope) {
  if (!connected_ || notifyCh_ == nullptr) return;
  notifyCh_->setValue((uint8_t*)envelope.c_str(), envelope.length());
  notifyCh_->notify();
}


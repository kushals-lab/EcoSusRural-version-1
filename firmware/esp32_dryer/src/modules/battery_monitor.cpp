// battery_monitor.cpp - divider on ADC1, 4-sample moving average, thresholds.
#include "modules/battery_monitor.h"

void BatteryMonitor::begin() {
  pinMode(PIN_BATTERY_ADC, INPUT);
  status_ = BatteryStatus{};
  rawVolts_ = 0.0f;
  for (uint8_t i = 0; i < 4; ++i) avg_[i] = 0.0f;
  avgIdx_ = 0;
}

float BatteryMonitor::readVolts() {
  int raw = analogRead(PIN_BATTERY_ADC);
  float vAdc = (raw / (float)ADC_MAX) * ADC_REF_V;
  return vAdc * BATT_DIVIDER_RATIO;
}

void BatteryMonitor::poll() {
  uint32_t now = millis();
  if (now - lastPoll_ < SENSOR_PERIOD_MS) return;
  lastPoll_ = now;

  avg_[avgIdx_] = readVolts();
  avgIdx_ = (avgIdx_ + 1) % 4;
  float sum = 0;
  for (uint8_t i = 0; i < 4; ++i) sum += avg_[i];
  rawVolts_ = sum / 4.0f;
  status_.volts = rawVolts_;

  // SOC is only an APPROXIMATE open-circuit estimate, clearly not exact.
  float span = BATT_FULL_V - BATT_EMPTY_V;
  float frac = (rawVolts_ - BATT_EMPTY_V) / span;
  if (frac < 0) frac = 0; if (frac > 1) frac = 1;
  status_.socPct = (int)(frac * 100.0f + 0.5f);

  status_.charging = false;  // no charge-detect input in reference prototype
  status_.lowWarn = rawVolts_ <= BATT_LOW_WARN_V;
  status_.critical = rawVolts_ <= BATT_CRITICAL_V;
}

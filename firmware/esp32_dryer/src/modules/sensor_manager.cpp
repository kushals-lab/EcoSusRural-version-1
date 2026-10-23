// sensor_manager.cpp - DS18B20 temps (OneWire), DHT RH, ADC airflow.
// Unavailable/disconnected sensors stay NaN so the app shows 'unavailable'.
#include <OneWire.h>
#include <DallasTemperature.h>
#include <DHT.h>
#include "modules/sensor_manager.h"

static OneWire oneWire(PIN_ONEWIRE);
static DallasTemperature ds(&oneWire);
static DHT dhtChamber(PIN_DHT_CHAMBER, DHT22);
static DHT dhtAmbient(PIN_DHT_AMBIENT, DHT22);

void SensorManager::begin() {
  ds.begin();
  dhtChamber.begin();
  dhtAmbient.begin();
  pinMode(PIN_AIRFLOW_ADC, INPUT);
}

void SensorManager::poll() {
  uint32_t now = millis();
  if (now - lastSample_ < SENSOR_PERIOD_MS) return;
  lastSample_ = now;
  sample();
}

void SensorManager::sample() {
  // Temperatures (DS18B20 by index 0,1,2 -> collector, chamber, ambient).
  ds.requestTemperatures();
  float collector = ds.getTempCByIndex(0);
  float chamber = ds.getTempCByIndex(1);
  float ambient = ds.getTempCByIndex(2);

  // Humidity (DHT22). NaN when read fails.
  float ch = dhtChamber.readHumidity();
  float am = dhtAmbient.readHumidity();
  float chT = dhtChamber.readTemperature();
  float amT = dhtAmbient.readTemperature();

  // Airflow (optional ADC). Map raw counts to a nominal 0..300 m3/h.
  float airflow = NAN;
  int raw = analogRead(PIN_AIRFLOW_ADC);
  if (raw > 20) {  // below this treat sensor as absent, not zero
    airflow = (raw / (float)ADC_MAX) * 300.0f;
  }

  // Plausibility gates -> health. NaN results are 'unavailable', not zero.
  health_.collectorOk = plausible(collector);
  health_.chamberOk = plausible(chamber);
  health_.ambientOk = plausible(ambient);
  health_.chamberRhOk = !isnan(ch) && ch >= 0 && ch <= 100;
  health_.ambientRhOk = !isnan(am) && am >= 0 && am <= 100;
  health_.airflowOk = !isnan(airflow);

  reading_.collectorC = health_.collectorOk ? collector : NAN;
  reading_.chamberC = health_.chamberOk ? chamber : NAN;
  reading_.ambientC = health_.ambientOk ? ambient : NAN;
  reading_.chamberRh = health_.chamberRhOk ? ch : NAN;
  reading_.ambientRh = health_.ambientRhOk ? am : NAN;
  reading_.airflow = health_.airflowOk ? airflow : NAN;
  reading_.ts = millis();
  // valid = required auto sensors healthy.
  reading_.valid = health_.collectorOk && health_.chamberOk &&
                   health_.ambientOk;
  (void)chT; (void)amT;  // DHT temp available if needed; OneWire preferred.
}

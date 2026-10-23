// main.cpp - EcoDryer ESP32 firmware entry point.
#include <Arduino.h>
#include "dryer_controller.h"

static DryerController controller;

void setup() {
  Serial.begin(115200);
  delay(200);
  controller.begin();
}

void loop() {
  controller.loop();
}

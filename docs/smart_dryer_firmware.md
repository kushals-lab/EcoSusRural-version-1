# ESP32 firmware spec (Arduino framework, solar-only, ~50 kg)

## Board + wiring (assumptions — confirm before mains wiring)

- ESP32 DevKit (BLE + Wi-Fi). No heater element in this design.
- Sensors: 3x DS18B20 (collector, chamber, ambient) + 2x SHT21/DHT22
  (chamber RH, ambient RH). Optional airflow (analog/FS3000).
- Actuators: 12 V DC fan via logic MOSFET + flyback diode, PWM 25 kHz;
  optional vent servo (SG90). Fused 12 V supply, common GND, star earth.
- Safety: independent 75 C bimetal cutout in series with fan supply,
  5 A fuse, IP-rated enclosure, cable glands, drip loops.

## Local control (must work with phone disconnected)

- 5 s loop: read sensors, validate ranges, run profile PI/fan curve,
  enforce `maxChamberTemp` (default 60 C): fan 100%, vent open,
  state `warning`; at 70 C or sensor loss: stop fan safely,
  state `safety_shutdown`, latch until manual reset + temps sane.
- Keep last profile in NVS; on reboot publish `warning` + restart flag,
  resume prior safe state (never auto-start drying).
- Validate every `cmd`: ranges, profile id, seq; reply `ack` with
  `accepted:true/false`.

## Endpoints / BLE

- Wi-Fi AP `EcoDryer-XXXX` (captive hint `http://192.168.4.1`):
  `GET /telemetry` -> telemetry envelope; `POST /cmd` -> ack.
- BLE service `ec00`: notify `ec01` (telemetry/state/alert, chunked),
  write `ec02` (cmd JSON, reassembled). Device name `EcoDryer-XXXX`.

## Telemetry example

`{"v":"1","type":"telemetry","seq":42,"data":{"collectorC":58.2,`
`"chamberC":49.1,"ambientC":31.4,"chamberRh":28.5,"ambientRh":55.0,`
`"airflow":140.0,"fanOn":true,"fanPwm":70,"vent":"open",`
`"state":"running"}}`

## Bring-up checklist

1. Flash, verify serial telemetry at 115200.
2. Heat-chamber test: confirm warning at 60 C, shutdown at 70 C.
3. Disconnect phone: confirm local control continues / safe state.
4. App Demo Mode first, then Wi-Fi, then BLE after plugin setup.

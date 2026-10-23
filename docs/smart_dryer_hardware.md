# ESP32 Smart Dryer — Hardware, pins, electrical interface

> These are the **reference-prototype** values used by the firmware in
> `firmware/esp32_dryer/include/dryer_config.h`. Verify against the actual
> schematic before wiring the 12 V rail. **Never connect a 12 V fan or the
> battery directly to a 3.3 V GPIO.**

## Board

- ESP32 DevKit (ESP32-WROOM-32), 3.3 V logic, ADC1 channels used.
- No mains. Single 12 V DC rail from battery, fused once at the source.
- Solar thermal collector is passive (no electrical heater in this design).

## Pin assignment table

| Signal | ESP32 GPIO | Direction | Interface | Notes |
|---|---|---|---|---|
| DS18B20 one-wire (collector, chamber, ambient) | GPIO4 | In | 1-Wire + 4.7 kΩ pull-up to 3.3 V | 3 sensors on one bus, parasitic/parasite-off |
| Chamber RH (SHT21/DHT22) | GPIO5 | In | I²C (SHT21) or 1-Wire (DHT22) | pull-up per sensor datasheet |
| Ambient RH (SHT21/DHT22) | GPIO18 | In | I²C / 1-Wire | as above |
| Airflow (optional, FS3000/analog) | GPIO34 | In | ADC1_CH6 (input-only) | 3.3 V max; divider if sensor is 5 V |
| Battery voltage sense | GPIO35 | In | ADC1_CH7 (input-only) | resistive divider into ADC, see below |
| Fan PWM (to MOSFET gate) | GPIO25 | Out | LEDC PWM 25 kHz, 8-bit | logic-level N-MOSFET gate |
| Fan tach (optional) | GPIO26 | In | digital, open-collector | stall detection where supported |
| Vent servo (optional SG90) | GPIO27 | Out | 50 Hz servo | damper actuator only if fitted |
| Safety cutout sense | GPIO32 | In | digital, pull-up; LOW = tripped | independent 75 °C bimetal, in series with fan supply |
| Status LED | GPIO2 | Out | via resistor to LED | on-board LED also fine |
| E-stop (optional button) | GPIO33 | In | active-low, internal pull-up | hardware E-stop if risk assessment requires |

## Fan driver circuit (12 V load, 3.3 V control)

```
3.3 V GPIO25 --[gate series R 100 Ω]-- MOSFET gate
12 V rail ----[5 A fuse]--+-- Fan(+) -------- MOSFET drain
                          |
                         (fan) 
                          |
                         Fan(-) --- MOSFET source --- GND
Flyback (Schottky) diode across Fan terminals, cathode to +12 V.
Gate pulled to GND with 10 kΩ so the fan is OFF at boot/reset.
```

- MOSFET: logic-level N-channel (Vgs(th) ≤ 2 V), rated ≥ 2× fan current
  (e.g. IRLZ44N; compatible: AO3400 for small fans, STP55NF06L).
- The **GPIO only switches the gate**; the 12 V load current flows through
  the MOSFET, never the ESP32 pin. Flyback diode is mandatory.
- 25 kHz PWM is above the audible band and inaudible in operation.
- Independent bimetal thermal cutout in series with the fan supply removes
  power on over-temperature even if firmware/MOSFET fails. Firmware reads
  the cutout as a sense line and latches `safety_shutdown`.

## Battery sense (divider)

```
Battery+ --[R1 47 kΩ]--+-- Battery- (GND)
                      |
                     [R2 10 kΩ]
                      |
                     GND
                      |
Node -> GPIO35 (ADC1_CH7), 0.1 µF to GND, clamp with 3.3 V zener if available
```

- Divider ratio ≈ (R1+R2)/R2 ≈ 5.7 (matches `BATT_DIVIDER_RATIO`).
- Maps 0–12.9 V to 0–2.26 V at the ADC. **Voltage ≠ state-of-charge**; use
  BMS SOC when available and treat voltage as a trend only.

## Electrical / safety interface notes

- Common ground between 12 V rail and ESP32; star-ground the fan return.
- Fuse the 12 V rail at the source (5 A) and the fan branch.
- IP-rated enclosure, cable glands, drip loops on all outdoor wiring.
- No mains in this design; the solar collector is passive air-heating.
- Software safety **supplements**, never replaces, the physical cutout,
  fusing, and isolation above.

## Components + compatible alternatives

| Function | Reference | Compatible alternatives |
|---|---|---|
| MCU | ESP32-WROOM-32 DevKit | ESP32-S2/S3 DevKit, TTGO T-Display |
| Temp sensors | DS18B20 (waterproof) | DS18B20 in epoxy, TMP36 (ADC) |
| RH sensors | SHT21 (I²C) | DHT22, SHT31, AHT10 |
| Airflow | FS3000 / analog | hot-wire, or omit (profile still runs) |
| Fan | 12 V DC blower, 25 kHz-capable | 12 V axial fan + matched driver |
| Fan driver | IRLZ44N logic MOSFET | AO3400, STP55NF06L, dedicated driver |
| Flyback diode | 1N5817 Schottky | SS14, any Schottky ≥ fan current |
| Vent servo | SG90 | MG90S, linear actuator with feedback |
| Battery | 12 V LiFePO4 4S | sealed lead-acid 12 V |
| Thermal cutout | 75 °C bimetal (NC) | 70–80 °C KSD9700 |
| Fuse | 5 A fast-blow + holder | blade fuse + inline holder |

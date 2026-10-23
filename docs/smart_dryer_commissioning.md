# Prototype commissioning & hardware-in-the-loop (HIL) validation

> These require the physical build. **No physical test below has been
> performed by the software alone.** Treat every line as a bench task with
> pass/fail evidence. Do not claim success until executed on real hardware.

## A. Bench bring-up (no crop)

1. Flash firmware (`pio run -t upload`); confirm serial at 115200 shows
   sensor readings every `SENSOR_PERIOD_MS` and state `IDLE/ready`.
2. Sensor sanity: compare each DS18B20/SHT reading to a reference
   thermometer/hygrometer; apply calibration offsets in Settings.
3. Fan hardware: with the fan disconnected, confirm MOSFET gate PWM on an
   oscilloscope/logic analyzer (25 kHz, duty tracks command). Confirm fan
   OFF at boot (gate held low by the 10 kΩ pull-down).
4. Connect the fan; confirm stall/tach detection triggers if supported,
   and that a physically blocked fan is reported as `FC_FAN_STALL`.

## B. Safety interlocks (mandatory before any crop)

5. Heat-chamber test (hair dryer/heat gun, supervised): confirm
   `warning` at `maxChamberTemp` (60 °C) → fan 100 %, vent open; confirm
   `safety_shutdown` latch at `cutoutChamberTemp` (70 °C).
6. Bimetal cutout: verify it opens independently of firmware and the fan
   loses power. Firmware must read the trip as a fault.
7. E-stop (if fitted): press and confirm immediate safe state; require
   deliberate reset to clear.
8. Sensor disconnect: unplug the chamber sensor mid-run; confirm sensor
   fault and that automatic operation does not continue unrestricted.
9. Low battery: discharge to `BATT_LOW_WARN_V` (warn) and
   `BATT_CRITICAL_V` (safe state, fan stop); confirm no unstable fan
   behavior near the threshold.

## C. Communication

10. Phone disconnect during drying: confirm local control + safety
    continue; on reconnect, readings are revalidated before auto resumes;
    if recovery is unsafe, device stays in safe state and notifies.
11. Wi-Fi AP: join `EcoDryer-Setup`, `GET /telemetry`, `POST /cmd`; confirm
    command validation rejects out-of-range fan/vent.
12. BLE: connect, enable notify, send `set_fan` beyond limit; confirm the
    controller clamps/rejects (app cannot bypass firmware limits).

## D. End-to-end drying (supervised, small batch)

13. Run a full session on a provisional profile; log temperature/RH/fan/
    battery to session history.
14. Verify elapsed-time completion is labelled **time-complete**, not
    certified dry, when no moisture/water-activity sensor is present.
15. Kill power mid-session; on reboot confirm the device recovers a safe
    state, does not auto-start drying, and requires revalidation.

## E. Evidence

Record for each step: date, hardware revision, firmware commit, measured
values, and pass/fail. File any fault logs (`FaultManager` ring buffer)
and attach them to the session record.

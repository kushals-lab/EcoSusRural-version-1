# Smart Solar Dryer protocol v1 (EcoSusRural + ESP32)

Envelope: JSON object with `v: "1"`, `type`, and payload.
BLE: split frames into ~180-byte chunks, reassemble by order.
Wi-Fi: `GET /telemetry` returns one envelope; `POST /cmd` takes one.

## Messages

- `hello` (app -> device): `{v,type:"hello",deviceId,ts}`
- `telemetry` (device -> app):
  `{v,type:"telemetry",seq,data:{collectorC,chamberC,ambientC,`
  `chamberRh,ambientRh,airflow,fanOn,fanPwm,vent,state}}`
- `state` (device -> app): `{v,type:"state",state,seq?}`
- `alert|fault` (device -> app): `{v,type:"alert",code,message}`
- `cmd` (app -> device):
  `{v,type:"cmd",seq,cmd,args?}` with cmd in
  `start|pause|stop|set_profile|set_fan|set_vent|`
  `simulate_fault|simulate_disconnect` (last two demo only).
- `ack` (device -> app): `{v,type:"ack",seq,accepted}`
- `error`: `{v,type:"error",message}`

## Rules

- Reject `v != "1"` with a visible protocol error.
- Commands need an `ack` within 8 s or the app shows a timeout.
- Telemetry older than 30 s is flagged STALE; missing fields show
  `unavailable`, never zero.
- States: ready|preparing|running|paused|completed|warning|
  safety_shutdown. Unknown strings map to Unknown (not shown as valid).
- The ESP32 validates every command and enforces its own safety
  shutdown; the app never overrides interlocks and never sends
  heater commands (solar-only design).

## BLE setup (when hardware is ready)

1. `flutter pub add flutter_blue_plus permission_handler`
2. Implement `BleDryerTransport.scan/connect/send`:
   scan for service UUID `ec00`, connect, enable notify on `ec01`,
   write commands (chunked) on `ec02`.
3. Request Android `BLUETOOTH_SCAN/CONNECT` + `ACCESS_FINE_LOCATION`
   via the existing `smart_dryer` permission entry.

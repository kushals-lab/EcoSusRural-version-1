/* Educational solar-dryer model shared by the browser and Node backend.
 * Illustrative coefficients, not calibrated hardware or food-safety guidance. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.EcoDryer = factory();
}(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';
  const CROPS = {
    mango: { name: 'Mango', initialMc: 80, targetMc: 15, color: '#ffb52d' },
    tomato: { name: 'Tomato', initialMc: 94, targetMc: 12, color: '#ed5e46' },
    chilli: { name: 'Chilli', initialMc: 75, targetMc: 10, color: '#c94232' },
    banana: { name: 'Banana', initialMc: 75, targetMc: 15, color: '#f8dc87' },
    apple: { name: 'Apple', initialMc: 85, targetMc: 15, color: '#ecad75' },
  };
  const clamp = (n, low, high) => Math.max(low, Math.min(high, n));
  const round = (n, digits = 2) => Number(n.toFixed(digits));
  const emptyTray = (id) => ({ id, inserted: true, crop: null, initialKg: 0, dryKg: 0, waterKg: 0, evaporatedKg: 0 });
  class DryerModel {
    constructor() { this.reset(); }
    reset() {
      this.sunlight = 850; this.ambientC = 28; this.ambientRh = 55;
      this.chamberC = 28; this.collectorC = 28; this.chamberRh = 55;
      this.fanPwm = 70; this.vent = 'open'; this.speed = 300;
      this.doorOpen = false; this.running = false; this.emergency = false;
      this.state = 'ready'; this.elapsedSec = 0; this.evapKgPerHour = 0;
      this.trays = Array.from({ length: 6 }, (_, i) => emptyTray(i + 1));
      this.events = []; this.revision = 0;
      this.note('Ready. Open the door, pull out a tray and load fruit.');
    }
    note(message) {
      this.events.unshift({ simulatedSeconds: round(this.elapsedSec, 0), message });
      this.events = this.events.slice(0, 30);
    }
    command(cmd, args = {}) {
      const reject = (message) => ({ accepted: false, message });
      const value = (key, low, high) => typeof args[key] === 'number' && Number.isFinite(args[key]) && args[key] >= low && args[key] <= high;
      const tray = this.trays.find((item) => item.id === args.trayId);
      if (cmd === 'reset') { this.reset(); return { accepted: true, message: 'Simulation reset.' }; }
      if (cmd === 'environment') {
        if (!value('sunlight', 0, 1100) || !value('ambientC', 5, 45) || !value('ambientRh', 10, 95) || !value('speed', 1, 1200)) return reject('Environment settings are outside the simulation limits.');
        this.sunlight = args.sunlight; this.ambientC = args.ambientC; this.ambientRh = args.ambientRh; this.speed = args.speed;
      } else if (cmd === 'door') {
        if (typeof args.open !== 'boolean') return reject('Choose open or closed.');
        if (!args.open && this.trays.some((item) => !item.inserted)) return reject('Insert all six trays before closing the door.');
        this.doorOpen = args.open;
        if (args.open && this.running) { this.running = false; this.state = 'paused'; }
        this.note(args.open ? 'Door opened. Drying fan stopped by the simulated interlock.' : 'Door closed. The batch can be started.');
      } else if (['pull_tray', 'insert_tray', 'load_tray', 'unload_tray'].includes(cmd)) {
        if (!this.doorOpen || !tray) return reject('Open the door and select a valid tray first.');
        if (cmd === 'pull_tray') tray.inserted = false;
        if (cmd === 'insert_tray') tray.inserted = true;
        if (cmd === 'load_tray') {
          if (tray.inserted) return reject('Pull the tray out before loading fruit.');
          if (tray.crop) return reject('Unload the current fruit before loading a new batch.');
          if (!CROPS[args.crop] || !value('massKg', 0.1, 2)) return reject('Choose a fruit and 0.1–2 kg per tray.');
          const crop = CROPS[args.crop];
          Object.assign(tray, { crop: args.crop, initialKg: args.massKg,
            dryKg: args.massKg * (1 - crop.initialMc / 100), waterKg: args.massKg * crop.initialMc / 100, evaporatedKg: 0 });
        }
        if (cmd === 'unload_tray') {
          if (tray.inserted) return reject('Pull the tray out before unloading fruit.');
          Object.assign(tray, emptyTray(tray.id), { inserted: false });
        }
        this.note(`Tray ${tray.id}: ${cmd.replace('_tray', '').replace('_', ' ')}${tray.crop ? ` · ${CROPS[tray.crop].name}` : ''}.`);
        if (this.state === 'completed') this.state = 'ready';
      } else if (cmd === 'start') {
        if (this.emergency) return reject('Reset the simulation after an emergency stop.');
        if (this.doorOpen) return reject('Close the door before starting.');
        if (this.chamberC >= 70) return reject('The simulated chamber is too hot. Reduce sunlight, open the outlet and let it cool.');
        if (!this.trays.some((item) => item.crop && item.inserted)) return reject('Load at least one tray with fruit.');
        if (this.trays.some((item) => item.crop && !item.inserted)) return reject('Insert every loaded tray first.');
        this.running = true; this.state = 'running'; this.note('Drying started. Sunlight warms the collector; moving air carries moisture out.');
      } else if (cmd === 'pause' || cmd === 'stop') {
        this.running = false; this.state = cmd === 'pause' ? 'paused' : 'ready';
        this.note(cmd === 'pause' ? 'Drying paused.' : 'Cycle stopped. Existing fruit and water balance are preserved.');
      } else if (cmd === 'emergency_stop') {
        this.running = false; this.emergency = true; this.state = 'safety_shutdown';
        this.note('Simulated emergency stop. Reset to start a new demonstration.');
      } else if (cmd === 'set_fan') {
        if (!value('pwm', 0, 100)) return reject('Fan speed must be 0–100%.');
        this.fanPwm = args.pwm;
      } else if (cmd === 'set_vent') {
        if (!['open', 'half', 'closed'].includes(args.vent)) return reject('Unknown vent position.');
        this.vent = args.vent;
      } else if (cmd === 'set_profile') {
        return reject('Load the desired fruit on each simulated tray to choose a profile.');
      } else return reject('Unsupported simulation command.');
      this.revision++;
      return { accepted: true, message: 'Simulation updated.' };
    }
    get airflow() {
      if (!this.running || this.doorOpen || this.emergency) return 0;
      return (this.fanPwm / 100 * 55 + 4) * ({ open: 1, half: 0.5, closed: 0 }[this.vent]);
    }
    advance(realSeconds) {
      let remaining = clamp(Number(realSeconds) || 0, 0, 10) * this.speed;
      let removed = 0;
      const totalSeconds = remaining;
      while (remaining > 0) {
        const dt = Math.min(5, remaining); remaining -= dt;
        const solarW = this.sunlight * 0.52 * 0.45 * 0.68;
        const targetCollector = this.ambientC + this.sunlight * 0.045;
        this.collectorC += (targetCollector - this.collectorC) * (1 - Math.exp(-dt / 90));
        const loaded = this.trays.filter((tray) => tray.crop && tray.inserted);
        const mass = loaded.reduce((sum, tray) => sum + tray.dryKg + tray.waterKg, 0);
        const lossWPerK = 1.8 + ({ open: 2.2, half: 1, closed: 0.1 }[this.vent]) + (this.doorOpen ? 14 : 0) + this.airflow / 3600 * 1.15 * 1005 * 0.15;
        const warm = Math.max(0, this.chamberC - this.ambientC);
        const humidityFactor = clamp((100 - this.chamberRh) / 60, 0.02, 1);
        const ventFactor = this.vent === 'closed' ? 0.03 : this.vent === 'half' ? 0.6 : 1;
        const active = this.running && !this.doorOpen && !this.emergency && loaded.length > 0;
        const availableEvapW = active ? Math.min(solarW * 0.6 + warm * 1.8, warm * 5) * humidityFactor * ventFactor : 0;
        const removableWater = loaded.reduce((sum, tray) => {
          const target = CROPS[tray.crop].targetMc / 100;
          return sum + Math.max(0, tray.waterKg - tray.dryKg * target / (1 - target));
        }, 0);
        const water = Math.min(removableWater, availableEvapW * dt / 2400000);
        if (water > 0) {
          for (const tray of loaded) {
            const target = CROPS[tray.crop].targetMc / 100;
            const available = Math.max(0, tray.waterKg - tray.dryKg * target / (1 - target));
            const share = Math.min(available, water * available / removableWater);
            tray.waterKg -= share; tray.evaporatedKg += share;
          }
          removed += water;
        }
        const evaporationW = water * 2400000 / dt;
        this.chamberC = clamp(this.chamberC + (solarW - warm * lossWPerK - evaporationW) * dt / (7000 + mass * 3000), this.ambientC, 90);
        if (this.chamberC >= 70 && this.running) {
          this.running = false; this.state = 'warning';
          this.note('Simulated overtemperature: cycle paused. Reduce sunlight and open the outlet.');
        }
        const targetRh = clamp(this.ambientRh - (this.chamberC - this.ambientC) * 0.9 + (active ? water / dt * 160000 : 0) + (this.vent === 'closed' && active ? 25 : 0), 10, 98);
        this.chamberRh += (targetRh - this.chamberRh) * (1 - Math.exp(-dt / 90));
        if (active) this.elapsedSec += dt;
        if (active && removableWater <= 0.000001) {
          this.running = false; this.state = 'completed';
          this.note('Illustrative moisture target reached. This is simulated completion, not a food-safety certification.');
        }
      }
      this.evapKgPerHour = totalSeconds > 0 ? removed / totalSeconds * 3600 : 0;
      this.revision++;
    }
    snapshot() {
      const trays = this.trays.map((tray) => {
        const massKg = tray.dryKg + tray.waterKg;
        const moisturePct = massKg > 0 ? tray.waterKg / massKg * 100 : null;
        const crop = CROPS[tray.crop];
        const progress = crop && moisturePct !== null ? clamp((crop.initialMc - moisturePct) / (crop.initialMc - crop.targetMc), 0, 1) : 0;
        return { ...tray, loaded: Boolean(tray.crop), cropName: crop?.name || 'Empty', massKg: round(massKg, 4),
          moisturePct: moisturePct === null ? null : round(moisturePct), targetMoisturePct: crop?.targetMc ?? null, progress: round(progress, 4) };
      });
      const loaded = trays.filter((tray) => tray.loaded);
      const currentMassKg = loaded.reduce((sum, tray) => sum + tray.dryKg + tray.waterKg, 0);
      const waterKg = loaded.reduce((sum, tray) => sum + tray.waterKg, 0);
      return { simulated: true, source: 'html_simulator', state: this.state, doorOpen: this.doorOpen,
        collectorC: round(this.collectorC), chamberC: round(this.chamberC), ambientC: this.ambientC,
        chamberRh: round(this.chamberRh), ambientRh: this.ambientRh, sunlight: this.sunlight,
        fanPwm: this.fanPwm, fanOn: this.running && !this.doorOpen && this.fanPwm > 0,
        airflow: round(this.airflow), vent: this.vent, simulationSpeed: this.speed,
        elapsedSimulatedSec: round(this.elapsedSec, 0), evapKgPerHour: round(this.evapKgPerHour, 4),
        initialMassKg: round(loaded.reduce((sum, tray) => sum + tray.initialKg, 0), 4), currentMassKg: round(currentMassKg, 4),
        waterRemovedKg: round(loaded.reduce((sum, tray) => sum + tray.evaporatedKg, 0), 4),
        moisturePct: currentMassKg > 0 ? round(waterKg / currentMassKg * 100) : null,
        progress: loaded.length ? round(loaded.reduce((sum, tray) => sum + tray.progress, 0) / loaded.length, 4) : 0,
        loadedTrayCount: loaded.length, trays, events: this.events, revision: this.revision };
    }
    telemetry(timestamp = new Date().toISOString()) {
      const s = this.snapshot();
      return { v: '1', type: 'telemetry', ts: timestamp, simulated: true, source: 'html_simulator', data: {
        collectorC: s.collectorC, chamberC: s.chamberC, ambientC: s.ambientC, inletC: round(s.ambientC + (s.collectorC - s.ambientC) * 0.6),
        exhaustC: round(s.chamberC - 1), chamberRh: s.chamberRh, ambientRh: s.ambientRh,
        exhaustRh: round(clamp(s.chamberRh + (s.evapKgPerHour > 0 ? 8 : 0), 0, 100)),
        airflow: s.airflow, fanOn: s.fanOn, fanPwm: s.fanPwm, vent: s.vent, state: s.state,
        mode: 'HTML_SIMULATION', bay: 'six-tray-reference', simulation: s,
      } };
    }
  }
  return { DryerModel, CROPS };
}));

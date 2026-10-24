'use strict';

(() => {
  const { DryerModel, CROPS } = window.EcoDryer;
  const localModel = new DryerModel();
  const $ = (id) => document.getElementById(id);
  const svg = (tag, attrs = {}) => {
    const element = document.createElementNS('http://www.w3.org/2000/svg', tag);
    for (const [key, value] of Object.entries(attrs)) element.setAttribute(key, String(value));
    return element;
  };
  let current = localModel.snapshot();
  let sessionId = null, online = false, polling = false, exploded = false, showAirflow = true, selectedTray = 1;
  let queue = Promise.resolve(), commandBusy = false, toastTimer;
  const trayNodes = [];
  const trayRows = [];
  const cropCache = [];
  const apiRoot = '/api/dryer-simulator';
  const onServer = ['http:', 'https:'].includes(location.protocol);

  function toast(message) {
    $('toast').textContent = message;
    $('toast').classList.add('visible');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => $('toast').classList.remove('visible'), 5000);
  }
  async function api(path, body) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 6000);
    try {
      const response = await fetch(`${apiRoot}${path}`, {
        method: body === undefined ? 'GET' : 'POST',
        ...(body === undefined ? {} : { headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }),
        signal: controller.signal, cache: 'no-store',
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.message || data.error || 'The simulator could not complete that action.');
      return data;
    } finally { clearTimeout(timeout); }
  }
  function connection(label, connected = false) {
    $('connection-label').textContent = label;
    $('connection-dot').classList.toggle('connected', connected);
  }
  async function connect() {
    if (!onServer) {
      window.open('http://127.0.0.1:5000/dryer-simulator/', '_blank', 'noopener');
      return;
    }
    connection('Connecting to backend…');
    $('connect-button').disabled = true;
    try {
      const saved = sessionStorage.getItem('ecosus.dryer.simulation');
      let state;
      if (saved) {
        try { state = await api(`/sessions/${encodeURIComponent(saved)}`); } catch (_) { /* Create a fresh, isolated simulation. */ }
      }
      state ||= await api('/sessions', {});
      sessionId = state.sessionId;
      sessionStorage.setItem('ecosus.dryer.simulation', sessionId);
      online = true;
      current = state;
      connection('Backend connected · app sync ready', true);
      $('connect-button').textContent = 'Reconnect';
      render();
    } catch (_) {
      online = false;
      connection('Local preview · app not connected');
      toast('Backend unavailable. You can explore locally; open this page through the running backend to sync the app.');
    } finally { $('connect-button').disabled = false; }
  }
  function command(cmd, args = {}) {
    queue = queue.then(async () => {
      commandBusy = true;
      try {
        if (online && sessionId) {
          const result = await api(`/sessions/${sessionId}/commands`, { cmd, args });
          current = result.snapshot;
        } else if (!onServer || !sessionId) {
          const result = localModel.command(cmd, args);
          if (!result.accepted) throw new Error(result.message);
          current = localModel.snapshot();
        } else throw new Error('Connection lost. Reconnect before changing this shared simulation.');
        render();
        return true;
      } catch (error) { toast(error.message || 'Could not update the simulation.'); return false; }
      finally { commandBusy = false; }
    });
    return queue;
  }
  async function poll() {
    if (!online || !sessionId || polling || commandBusy) return;
    polling = true;
    try {
      current = await api(`/sessions/${sessionId}`);
      connection('Backend connected · app sync ready', true);
      render();
    } catch (_) {
      // Freeze the last shared state. Never silently generate different phone data.
      connection('Connection lost · last shared snapshot');
      $('phone-status').textContent = 'App synchronization unavailable';
    } finally { polling = false; }
  }

  function makeFruit(crop, index) {
    const group = svg('g');
    const x = 365 + (index % 6) * 32 + (index >= 6 ? 12 : 0);
    const y = index < 6 ? -14 : -25;
    group.setAttribute('transform', `translate(${x} ${y})`);
    if (crop === 'chilli') {
      group.append(svg('path', { d: 'M-10 -2Q-12 6 0 7Q11 5 14-5Q3 3-10-2Z', fill: index % 3 ? '#d85839' : '#88a452', stroke: '#752b20', 'stroke-width': .5 }));
      group.append(svg('path', { d: 'M-9-2L-14-6', stroke: '#6e934d', 'stroke-width': 2, fill: 'none' }));
    } else if (crop === 'tomato') {
      group.append(svg('ellipse', { rx: 12, ry: 6, fill: '#df6650', stroke: '#faad82', 'stroke-width': 1 }));
      group.append(svg('path', { d: 'M-6 0L0-3L6 0L0 3Z', fill: '#efad76', opacity: .7 }));
      group.append(svg('circle', { r: 1.4, fill: '#758a45' }));
    } else {
      group.append(svg('ellipse', { rx: crop === 'banana' ? 9 : 13, ry: 5, fill: CROPS[crop].color, stroke: '#fbe9a9', 'stroke-width': 1, transform: `rotate(${index % 2 ? -12 : 14})` }));
      group.append(svg('path', { d: 'M-7-1Q0-4 7-1', stroke: '#fff4bd', 'stroke-width': 1, fill: 'none', opacity: .7 }));
    }
    return group;
  }
  function initDiagram() {
    for (let i = 0; i < 6; i++) {
      const y = 275 + i * 50;
      const group = svg('g', { class: 'tray-g', 'data-tray': i + 1 });
      const inner = svg('g', { transform: `translate(0 ${y})` });
      inner.append(svg('path', { d: 'M350 0H570L623-24H402Z', fill: '#677e6d', stroke: '#a7b7a6', 'stroke-width': 1.5 }));
      inner.append(svg('path', { d: 'M353-1H568L619-22H404Z', fill: 'url(#mesh)' }));
      const fruit = svg('g', { class: 'fruit-g' });
      inner.append(fruit);
      inner.append(svg('path', { class: 'tray-front', d: 'M350 0H570V8H350Z', fill: '#83978a', stroke: '#bcc8b9', 'stroke-width': 1 }));
      const number = svg('text', { x: 355, y: 7, class: 'tray-number' }); number.textContent = String(i + 1); inner.append(number);
      group.append(inner);
      group.addEventListener('click', () => { selectedTray = i + 1; render(); toast(`Tray ${i + 1} selected. Use its Pull out / Load / Insert controls.`); });
      $('tray-layer').append(group);
      trayNodes.push({ group, fruit });
      for (let j = 0; j < 3; j++) {
        const vapour = svg('g', { class: 'vapour', style: `animation-delay:${-(i * .31 + j * .8)}s` });
        vapour.append(svg('path', { d: 'M0-7Q-6 0-4 3Q0 8 4 3Q6 0 0-7Z', transform: `translate(${400 + j * 55} ${y - 21})`, opacity: .75 }));
        vapour.dataset.tray = String(i + 1);
        $('vapour-layer').append(vapour);
      }
      const row = document.createElement('div'); row.className = 'tray-row'; row.dataset.tray = i + 1;
      const index = document.createElement('span'); index.className = 'tray-index'; index.textContent = i + 1;
      const detail = document.createElement('div');
      const name = document.createElement('div'); name.className = 'tray-name';
      const description = document.createElement('div'); description.className = 'tray-detail';
      detail.append(name, description);
      const buttons = document.createElement('div'); buttons.className = 'tray-buttons';
      const position = document.createElement('button');
      position.addEventListener('click', () => { selectedTray = i + 1; command(current.trays[i].inserted ? 'pull_tray' : 'insert_tray', { trayId: i + 1 }); });
      const load = document.createElement('button'); load.className = 'load-btn';
      load.addEventListener('click', () => {
        selectedTray = i + 1;
        command(current.trays[i].loaded ? 'unload_tray' : 'load_tray', { trayId: i + 1, crop: $('fruit').value, massKg: Number($('mass').value) });
      });
      buttons.append(position, load); row.append(index, detail, buttons); $('tray-controls').append(row);
      trayRows.push({ row, name, description, position, load });
    }
    for (const cx of [395, 531]) {
      const fan = svg('g');
      fan.append(svg('rect', { x: cx - 30, y: 658, width: 60, height: 60, rx: 3, fill: '#25362b', stroke: '#83917b', 'stroke-width': 2 }));
      fan.append(svg('circle', { cx, cy: 688, r: 25, fill: '#1e2d24', stroke: '#a1b099', 'stroke-width': 1.4 }));
      const blades = svg('g', { class: 'fan-spin' });
      for (let i = 0; i < 5; i++) blades.append(svg('path', { d: `M${cx} 688Q${cx - 24} 665 ${cx - 4} 668Q${cx + 8} 671 ${cx} 688Z`, fill: '#8f9e85', transform: `rotate(${i * 72} ${cx} 688)` }));
      fan.append(blades, svg('circle', { cx, cy: 688, r: 5, fill: '#cad1bd' }));
      for (const radius of [16, 21]) fan.append(svg('circle', { cx, cy: 688, r: radius, fill: 'none', stroke: '#b7c2a6', 'stroke-width': .8, opacity: .65 }));
      $('fans').append(fan);
    }
  }

  function render() {
    const s = current;
    $('temperature').innerHTML = `${s.chamberC.toFixed(1)} <small>°C</small>`;
    $('ambient-label').textContent = `Outside ${s.ambientC} °C · Chamber RH ${s.chamberRh.toFixed(0)}%`;
    $('moisture').innerHTML = `${s.moisturePct === null ? '—' : s.moisturePct.toFixed(1)} <small>%</small>`;
    $('water').innerHTML = `${s.waterRemovedKg.toFixed(3)} <small>kg</small>`;
    $('evap-rate').textContent = `${s.evapKgPerHour.toFixed(3)} kg / simulated hour`;
    $('weight').innerHTML = `${s.currentMassKg.toFixed(3)} <small>kg</small>`;
    $('load-label').textContent = `${s.loadedTrayCount} of 6 trays loaded · ${s.initialMassKg.toFixed(2)} kg fresh`;
    $('progress').value = s.progress;
    $('progress-label').textContent = `${Math.round(s.progress * 100)}%`;
    $('door-button').textContent = s.doorOpen ? 'Close door' : 'Open door';
    $('door-button').setAttribute('aria-pressed', String(s.doorOpen));
    $('door').classList.toggle('open', s.doorOpen);
    $('door').classList.toggle('exploded-door', exploded);
    $('solar-panel').setAttribute('transform', exploded ? 'translate(0 -95)' : '');
    $('top-cover').setAttribute('transform', exploded ? 'translate(0 -50)' : '');
    $('base-unit').setAttribute('transform', exploded ? 'translate(0 28)' : '');
    $('battery').setAttribute('transform', exploded ? 'translate(35 0)' : '');
    $('cabinet').style.opacity = exploded ? '.8' : '1';
    $('dryer-svg').classList.toggle('running', s.fanOn);
    $('dryer-svg').classList.toggle('flowing', showAirflow && s.airflow > 0 && !exploded);
    $('dryer-svg').classList.toggle('evaporating', s.evapKgPerHour > 0.00001 && !s.doorOpen && !exploded);
    $('heat-glow').style.opacity = Math.min(1, Math.max(0, (s.chamberC - s.ambientC) / 20));
    $('sun-group').style.opacity = .15 + s.sunlight / 1100 * .85;
    $('sun-beams').style.opacity = s.sunlight / 1100 * .8;
    $('lcd-temp').textContent = `${s.chamberC.toFixed(1)}°C`;
    $('run-led').setAttribute('fill', s.state === 'running' ? '#b7da76' : '#889c79');
    const labels = { ready: 'Ready to load', running: 'Drying in sunshine', paused: 'Paused', completed: 'Simulation complete', warning: 'Temperature warning · paused', safety_shutdown: 'Emergency stop' };
    $('state-chip').textContent = s.doorOpen ? 'Door open · fan interlock' : labels[s.state] || s.state;
    $('state-chip').className = `status-chip ${s.state}`;
    const minutes = Math.floor(s.elapsedSimulatedSec / 60);
    $('time-label').textContent = `${Math.floor(minutes / 60)}h ${String(minutes % 60).padStart(2, '0')}m simulated`;
    $('start-button').disabled = s.doorOpen || s.loadedTrayCount === 0 || s.state === 'running' || s.state === 'safety_shutdown';
    $('pause-button').disabled = s.state !== 'running';
    $('sunlight-value').textContent = `${s.sunlight} W/m²`;
    $('speed-value').textContent = `${s.simulationSpeed}×`;
    $('speed-hint').textContent = `1 real second = ${(s.simulationSpeed / 60).toFixed(1)} simulated minutes`;
    for (const [id, value] of [['sunlight', s.sunlight], ['ambient', s.ambientC], ['humidity', s.ambientRh], ['speed', s.simulationSpeed], ['fan', s.fanPwm], ['vent', s.vent]]) {
      if (document.activeElement !== $(id)) $(id).value = value;
    }
    $('tray-instruction').textContent = s.doorOpen ? 'Door is open. Pull a tray out to load or unload fruit.' : 'Open door → pull tray out → load fruit → insert tray.';
    s.trays.forEach((tray, i) => {
      const { group, fruit } = trayNodes[i];
      group.setAttribute('transform', `translate(${tray.inserted ? 0 : -110} ${exploded ? -(6 - i) * 16 : 0})`);
      group.classList.toggle('selected', selectedTray === tray.id);
      if (cropCache[i] !== tray.crop) {
        fruit.replaceChildren();
        if (tray.crop) for (let j = 0; j < 12; j++) fruit.append(makeFruit(tray.crop, j));
        cropCache[i] = tray.crop;
      }
      fruit.style.transform = `scale(${1 - tray.progress * .3})`;
      const row = trayRows[i]; row.row.classList.toggle('loaded', tray.loaded);
      row.name.textContent = tray.loaded ? `${tray.cropName} · ${tray.massKg.toFixed(3)} kg` : 'Empty tray';
      row.description.textContent = `${tray.inserted ? 'Inserted' : 'Pulled out'}${tray.moisturePct === null ? '' : ` · ${tray.moisturePct.toFixed(1)}% moisture`}`;
      row.position.textContent = tray.inserted ? 'Pull out' : 'Insert';
      row.position.setAttribute('aria-label', `${tray.inserted ? 'Pull out' : 'Insert'} tray ${tray.id}`);
      row.position.disabled = !s.doorOpen;
      row.load.textContent = tray.loaded ? 'Unload' : 'Load';
      row.load.setAttribute('aria-label', `${tray.loaded ? 'Unload' : 'Load'} tray ${tray.id}`);
      row.load.disabled = !s.doorOpen || tray.inserted;
    });
    for (const vapour of $('vapour-layer').children) vapour.style.display = s.trays[Number(vapour.dataset.tray) - 1].loaded ? '' : 'none';
    $('event-log').replaceChildren();
    for (const entry of s.events.slice(0, 8)) {
      const li = document.createElement('li'); const time = document.createElement('time');
      time.textContent = `${Math.floor(entry.simulatedSeconds / 3600)}:${String(Math.floor(entry.simulatedSeconds / 60) % 60).padStart(2, '0')}`;
      const text = document.createElement('span'); text.textContent = entry.message;
      li.append(time, text); $('event-log').append(li);
    }
    if (sessionId) {
      $('pair-code').textContent = s.pairingCode || '— — — — — —';
      const seen = s.lastAppSeenAt ? Date.now() - Date.parse(s.lastAppSeenAt) : Infinity;
      $('phone-status').textContent = seen < 10000 ? 'Phone connected · updating' : seen < 60000 ? 'Phone last seen recently' : 'Waiting for the phone';
    }
  }
  function view(isExploded) {
    exploded = isExploded;
    for (const [id, selected] of [['assembled-button', !exploded], ['exploded-button', exploded]]) {
      $(id).classList.toggle('selected', selected); $(id).setAttribute('aria-pressed', String(selected));
    }
    render();
  }
  function environment() {
    command('environment', { sunlight: Number($('sunlight').value), ambientC: Number($('ambient').value), ambientRh: Number($('humidity').value), speed: Number($('speed').value) });
  }
  $('door-button').addEventListener('click', () => command('door', { open: !current.doorOpen }));
  $('door').addEventListener('click', () => command('door', { open: !current.doorOpen }));
  $('door').addEventListener('keydown', (event) => { if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); command('door', { open: !current.doorOpen }); } });
  $('start-button').addEventListener('click', () => command('start'));
  $('pause-button').addEventListener('click', () => command('pause'));
  $('assembled-button').addEventListener('click', () => view(false));
  $('exploded-button').addEventListener('click', () => view(true));
  $('airflow-button').addEventListener('click', () => { showAirflow = !showAirflow; $('airflow-button').textContent = showAirflow ? 'Airflow visible' : 'Show airflow'; $('airflow-button').setAttribute('aria-pressed', String(showAirflow)); render(); });
  for (const id of ['sunlight', 'ambient', 'humidity', 'speed']) $(id).addEventListener('change', environment);
  $('sunlight').addEventListener('input', () => { $('sunlight-value').textContent = `${$('sunlight').value} W/m²`; });
  $('speed').addEventListener('input', () => { $('speed-value').textContent = `${$('speed').value}×`; });
  $('fan').addEventListener('change', () => command('set_fan', { pwm: Number($('fan').value) }));
  $('vent').addEventListener('change', () => command('set_vent', { vent: $('vent').value }));
  $('connect-button').addEventListener('click', connect);
  $('sample-button').addEventListener('click', async () => {
    if (current.loadedTrayCount && !confirm('Replace the current simulated fruit with a new sample batch?')) return;
    view(false);
    await command('reset');
    await command('door', { open: true });
    for (let i = 1; i <= 6; i++) {
      await command('pull_tray', { trayId: i });
      await command('load_tray', { trayId: i, crop: i <= 2 ? 'mango' : i <= 4 ? 'tomato' : 'chilli', massKg: .3 });
      await command('insert_tray', { trayId: i });
    }
    await command('door', { open: false });
    await command('start');
    toast('Sample batch started: mango, tomato and chilli. Change the sunlight or open the door to explore.');
  });
  $('reset-button').addEventListener('click', () => { if (confirm('Reset this simulation and clear its fruit? This does not affect real dryer records.')) command('reset'); });
  $('help-button').addEventListener('click', () => $('help-dialog').showModal());
  $('close-help').addEventListener('click', () => $('help-dialog').close());
  initDiagram(); render();
  if (onServer) connect();
  else { connection('Local preview · no app sync'); $('phone-status').textContent = 'Open through the backend to pair'; }
  setInterval(() => {
    if (online) poll();
    else if (!sessionId && !commandBusy) { localModel.advance(1); current = localModel.snapshot(); render(); }
  }, 1000);
})();

'use strict';
(() => {
  const $ = id => document.getElementById(id);
  let session, state, busy = false, polling = false, connected = false, epoch = 0;
  const controls = ['start', 'pause', 'reset', 'boost', 'produceSelect'];
  function status(message, ok) {
    connected = ok;
    $('conn').textContent = message;
    $('conn').className = `conn ${ok ? 'ok' : 'error'}`;
    controls.forEach(id => { $(id).disabled = !ok || busy; });
    if (!ok) $('root').classList.add('stopped');
  }
  async function api(path, body) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 6000);
    try {
      const response = await fetch('/api/dryer-simulator' + path, {
        method: body ? 'POST' : 'GET', signal: controller.signal, cache: 'no-store',
        headers: body ? {'Content-Type': 'application/json'} : {},
        body: body ? JSON.stringify(body) : undefined,
      });
      const data = await response.json();
      if (!response.ok) throw Error(data.message || data.error || 'Simulation request failed.');
      return data;
    } finally { clearTimeout(timer); }
  }
  function render() {
    const s = state;
    const crop = s.trays.find(t => t.loaded);
    for (const key of ['collector', 'chamber']) $(key + 'Temp').textContent = s[key + 'C'].toFixed(1) + ' °C';
    $('humidity').textContent = s.chamberRh.toFixed(0) + '%';
    $('appTemp').textContent = $('chamberTemp').textContent;
    $('appHumidity').textContent = $('humidity').textContent;
    $('airflow').textContent = s.airflow.toFixed(1) + ' m³/h';
    $('item').textContent = crop ? crop.cropName : 'No produce loaded';
    if (crop && !busy) $('produceSelect').value = crop.crop;
    $('progress').textContent = Math.round(s.progress * 100) + '%';
    $('bar').style.width = $('progress').textContent;
    $('mode').textContent = s.state.replaceAll('_', ' ').toUpperCase();
    $('fan').textContent = s.fanOn ? s.fanPwm + '%' : 'Paused';
    $('boost').textContent = s.fanPwm === 100 ? 'Return to normal airflow' : 'Boost airflow';
    $('pause').textContent = s.state === 'running' ? 'Pause' : 'Resume';
    $('code').textContent = s.pairingCode;
    $('root').classList.toggle('stopped', !connected || s.airflow <= 0);
    $('rays').style.opacity = Math.max(.12, s.sunlight / 1100);
    $('heat').setAttribute('stop-color', s.sunlight > 400 ? '#f2c94c' : '#a8a8a8');
    const group = $('produce'); group.replaceChildren();
    s.trays.forEach((tray, index) => {
      if (!tray.loaded) return;
      for (let x = 525; x < 640; x += 32) {
        const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
        circle.setAttribute('cx', x); circle.setAttribute('cy', 150 + index * 36);
        circle.setAttribute('r', 8 * (1 - tray.progress * .3));
        circle.setAttribute('fill', tray.progress > .5 ? '#b27a43' : '#90a955');
        group.append(circle);
      }
    });
    $('stage').textContent = s.state === 'completed' ? 'Drying complete (simulation).' :
      s.doorOpen ? 'Door open: airflow stopped.' : s.state === 'running' ?
      'Drying: browser and app share these simulation readings.' : `Simulation ${s.state.replaceAll('_', ' ')}.`;
  }
  async function command(cmd, args = {}) {
    const result = await api(`/sessions/${session}/commands`, {cmd, args});
    state = result.snapshot; render();
  }
  async function configure(crop) {
    await command('reset');
    await command('door', {open: true});
    await command('pull_tray', {trayId: 1});
    await command('load_tray', {trayId: 1, crop, massKg: .3});
    await command('insert_tray', {trayId: 1});
    await command('door', {open: false});
    $('note').textContent = 'Selected item loaded into tray 1.';
  }
  async function action(work) {
    if (!connected || busy) return;
    busy = true; epoch++;
    status('Updating shared simulation…', true);
    try { await work(); }
    catch (error) { status(error.message, false); }
    finally {
      busy = false;
      status(connected ? 'Shared simulation connected' : $('conn').textContent, connected);
      if (connected) render();
    }
  }
  $('produceSelect').onchange = () => {
    const crop = $('produceSelect').value;
    void action(() => configure(crop));
  };
  $('reset').onclick = () => { const crop = $('produceSelect').value; void action(() => configure(crop)); };
  $('start').onclick = () => action(async () => {
    if (!state.loadedTrayCount) await configure($('produceSelect').value);
    await command('start');
  });
  $('pause').onclick = () => action(() => command(state.state === 'running' ? 'pause' : 'start'));
  $('boost').onclick = () => action(() => command('set_fan', {pwm: state.fanPwm === 100 ? 70 : 100}));
  async function poll() {
    if (!session || busy || polling) return;
    polling = true; const version = epoch;
    try {
      const next = await api(`/sessions/${session}`);
      if (version !== epoch) return;
      state = next; status('Shared simulation connected', true); render();
    } catch (error) {
      if (version === epoch) status('Connection lost. Readings are stale. ' + error.message, false);
    } finally { polling = false; }
  }
  async function connect() {
    status('Connecting to shared simulator…', false);
    try {
      let saved;
      try { saved = sessionStorage.getItem('ecosus.dryer.simulation'); } catch (_) { /* Storage is optional. */ }
      if (saved) { try { state = await api('/sessions/' + encodeURIComponent(saved)); } catch (_) { /* Expired session. */ } }
      state ||= await api('/sessions', {});
      session = state.sessionId;
      try { sessionStorage.setItem('ecosus.dryer.simulation', session); } catch (_) { /* Storage is optional. */ }
      status('Shared simulation connected', true); render();
    } catch (error) { status('Unable to connect. Open this page through the backend and reload. ' + error.message, false); }
  }
  void connect(); setInterval(poll, 1000);
})();

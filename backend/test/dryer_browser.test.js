const {test} = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const {createDryerSessions} = require('../src/simulation/dryerSessions');

test('browser guards overlapping commands and reports connection loss and recovery', async () => {
  const sessions = createDryerSessions({tickAutomatically: false});
  const elements = new Map(); let poll, fail = false, requests = 0;
  const element = () => ({style: {}, classList: {add() {}, toggle() {}},
    setAttribute() {}, replaceChildren() {}, append() {}, value: 'mango'});
  const get = id => { if (!elements.has(id)) elements.set(id, element()); return elements.get(id); };
  const context = {
    document: {getElementById: get, createElementNS: element},
    sessionStorage: {getItem() {}, setItem() {}}, AbortController, setTimeout, clearTimeout,
    setInterval(fn) { poll = fn; },
    async fetch(url, options) {
      requests++;
      if (fail) throw Error('Offline');
      const body = options.body && JSON.parse(options.body);
      const parts = url.split('/'); let data;
      if (body && parts.at(-1) === 'sessions') data = sessions.create();
      else if (body) data = sessions.command(parts.at(-2), body.cmd, body.args);
      else data = sessions.read(parts.at(-1));
      return {ok: true, json: async () => data};
    },
  };
  try {
    vm.runInNewContext(fs.readFileSync(require.resolve('../../simulator/item-selection.js'), 'utf8'), context);
    assert.equal(get('start').disabled, true);
    await new Promise(setImmediate);
    assert.equal(get('start').disabled, false);
    const first = get('start').onclick();
    const second = get('start').onclick();
    await Promise.all([first, second]);
    assert.equal(get('mode').textContent, 'RUNNING');
    assert.equal(requests, 8); // create + six loading commands + start
    await get('boost').onclick();
    assert.equal(get('boost').textContent, 'Return to normal airflow');
    fail = true; await poll();
    assert.match(get('conn').textContent, /stale/);
    assert.equal(get('boost').disabled, true);
    fail = false; await poll();
    assert.equal(get('boost').disabled, false);
    await get('pause').onclick();
    assert.equal(get('pause').textContent, 'Resume');
  } finally { sessions.close(); }
});

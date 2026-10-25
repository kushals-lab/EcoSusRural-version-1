'use strict';
// Run `node scripts/record_dryer_video.js` on Windows with Chrome installed.
// Records the real six-tray model into a portable WebM in docs/.
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const {spawn} = require('node:child_process');
const {pathToFileURL} = require('node:url');

const root = path.resolve(__dirname, '..');
const chrome = [
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
].find(fs.existsSync);
if (!chrome) throw Error('Chrome or Edge is required to record the video.');
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'ecosus-dryer-record-'));
const proc = spawn(chrome, ['--headless=new', '--no-first-run', '--disable-background-networking',
  '--remote-debugging-port=0', `--user-data-dir=${profile}`, 'about:blank'], {stdio: 'ignore'});
let socket, nextId = 0;
const pending = new Map();
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
async function waitForPort() {
  for (let i = 0; i < 100; i++) {
    const file = path.join(profile, 'DevToolsActivePort');
    if (fs.existsSync(file)) return Number(fs.readFileSync(file, 'utf8').split('\n')[0]);
    if (proc.exitCode != null) throw Error('Browser exited before recording.');
    await delay(100);
  }
  throw Error('Browser debugging endpoint did not start.');
}
async function send(method, params = {}) {
  const id = ++nextId;
  const result = new Promise((resolve, reject) => pending.set(id, {resolve, reject}));
  socket.send(JSON.stringify({id, method, params}));
  return result;
}
async function run() {
  const port = await waitForPort();
  const pages = await (await fetch(`http://127.0.0.1:${port}/json`)).json();
  socket = new WebSocket(pages.find(page => page.type === 'page').webSocketDebuggerUrl);
  await new Promise((resolve, reject) => { socket.onopen = resolve; socket.onerror = reject; });
  socket.onmessage = event => {
    const response = JSON.parse(event.data);
    if (!pending.has(response.id)) return;
    const promise = pending.get(response.id); pending.delete(response.id);
    response.error ? promise.reject(Error(response.error.message)) : promise.resolve(response.result);
  };
  await send('Page.enable');
  await send('Page.navigate', {url: pathToFileURL(path.join(root, 'scripts', 'dryer_video_canvas.html')).href});
  await delay(500);
  const result = await send('Runtime.evaluate', {expression: 'window.recordDryerVideo()', awaitPromise: true, returnByValue: true});
  if (result.exceptionDetails || !result.result?.value) throw Error('Video recorder failed in browser.');
  const video = Buffer.from(result.result.value, 'base64');
  if (video.length < 10000 || !video.subarray(0, 4).equals(Buffer.from([0x1a, 0x45, 0xdf, 0xa3]))) {
    throw Error('The resulting WebM is empty or invalid.');
  }
  const destination = path.join(root, 'docs', 'solar_dryer_simulation_demo.webm');
  fs.writeFileSync(destination, video);
  console.log(`${destination} (${video.length} bytes)`);
}
run().catch(error => { console.error(error); process.exitCode = 1; }).finally(async () => {
  socket?.close(); proc.kill();
  if (proc.exitCode == null) await new Promise(resolve => { proc.once('exit', resolve); setTimeout(resolve, 3000); });
  try { fs.rmSync(profile, {recursive: true, force: true, maxRetries: 10, retryDelay: 300}); }
  catch (error) { console.warn('Temporary browser profile could not be removed:', error.message); }
});

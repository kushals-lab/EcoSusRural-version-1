// Scan project files without printing secret values. Run before uploading.
// This is a local heuristic check, not a replacement for a hosting secret scanner.
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { execFileSync, spawnSync } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const skipped = new Set([
  '.git', '.dart_tool', '.pub-cache', '.pub', '.venv', 'venv', '__pycache__',
  'node_modules', 'build', 'dist', 'coverage', 'ephemeral', '.gradle',
  'empty_url_launcher_windows_cache_backup',
]);
const textExtensions = /\.(?:dart|js|cjs|mjs|ts|tsx|jsx|py|json|ya?ml|toml|xml|properties|gradle|kts|kt|java|swift|m|mm|h|cpp|cc|sh|ps1|sql|md|txt|env)$/i;
const tracked = execFileSync('git', ['ls-files', '-z'], { cwd: root, encoding: 'utf8' }).split('\0').filter(Boolean);
const sensitivePath = (file) => {
  const name = path.basename(file);
  if (name === '.env.example' || name === '.env.backend.example') return false;
  return name === '.env' || name.startsWith('.env.') ||
    /\.(?:pem|key|jks|keystore|p12|pfx)$/i.test(name) || name === 'key.properties';
};
const findings = new Set();
const skippedPaths = [];
for (const file of tracked) {
  if (sensitivePath(file)) findings.add(`${file}: tracked environment or signing file; untrack it before upload`);
}

const localSecrets = new Set();
for (const envFile of ['.env.local', 'backend/.env.local', 'ai_service/.env.local']) {
  const full = path.join(root, envFile);
  if (!fs.existsSync(full)) continue;
  for (const line of fs.readFileSync(full, 'utf8').split(/\r?\n/)) {
    const entry = line.match(/^\s*([\w]+)\s*=\s*(.*?)\s*$/);
    if (!entry || !/KEY|TOKEN|SECRET|PASSWORD|(?:^|_)PASS$|MONGODB_URI/i.test(entry[1]) || /CLIENT_ID/i.test(entry[1])) continue;
    const value = entry[2].replace(/^(['"])(.*)\1$/, '$2');
    for (const candidate of [value, ...value.split(','), ...(entry[1] === 'SMTP_PASS' ? [value.replace(/\s/g, '')] : [])]) {
      if (candidate.length >= 16 && !/^(?:your[-_]|replace[-_]|example)/i.test(candidate)) localSecrets.add(candidate);
    }
    if (entry[1] === 'MONGODB_URI') {
      try {
        const password = decodeURIComponent(new URL(value).password);
        if (password.length >= 8) localSecrets.add(password);
      } catch (_) { /* Malformed local values are not printed. */ }
    }
  }
}
const patterns = [
  ['private key material', /-----BEGIN (?:RSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----/],
  ['credential in database URL', /mongodb(?:\+srv)?:\/\/[^\s:'"<>]+:[^\s@'"<>]+@/],
  ['Google API key literal', /AIza[0-9A-Za-z_-]{30,}/],
  ['provider token literal', /(?:sk-(?:proj-)?[A-Za-z0-9_-]{24,}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})/],
  ['assigned credential literal', /\b(?:api[_-]?key|access[_-]?token|client[_-]?secret|jwt[_-]?secret|password)\s*[:=]\s*['"][A-Za-z0-9_+./=-]{24,}['"]/i],
];
let scanned = 0;
function walk(directory) {
  let entries;
  try { entries = fs.readdirSync(directory, { withFileTypes: true }); }
  catch (_) { skippedPaths.push(path.relative(root, directory)); return; }
  for (const entry of entries) {
    const full = path.join(directory, entry.name);
    const relative = path.relative(root, full).split(path.sep).join('/');
    if (entry.isSymbolicLink()) continue;
    if (entry.isDirectory()) {
      if (!skipped.has(entry.name)) walk(full);
      continue;
    }
    if (sensitivePath(relative) && !tracked.includes(relative)) continue;
    if (!textExtensions.test(entry.name) && !entry.name.startsWith('.env')) continue;
    if (fs.statSync(full).size > 2 * 1024 * 1024) continue;
    scanned++;
    const lines = fs.readFileSync(full, 'utf8').split(/\r?\n/);
    lines.forEach((line, index) => {
      if ([...localSecrets].some((secret) => line.includes(secret))) {
        findings.add(`${relative}:${index + 1}: contains a credential from local environment`);
      }
      for (const [label, pattern] of patterns) {
        if (!pattern.test(line)) continue;
        // Examples and deliberate test fixtures are reviewable, not active credentials.
        if (/example|placeholder|test[-_ ]only|test-client|username:password|<password>/i.test(line)) continue;
        findings.add(`${relative}:${index + 1}: ${label}; review required`);
      }
    });
  }
}
walk(root);
if (process.argv.includes('--history') && localSecrets.size) {
  const commits = execFileSync('git', ['rev-list', '--all'], { cwd: root, encoding: 'utf8' }).trim().split(/\r?\n/).filter(Boolean);
  console.log(`Checking ${commits.length} Git commit(s) for credentials known from local configuration.`);
  for (const commit of commits) {
    const result = spawnSync('git', ['grep', '-I', '-l', '-F', '-f', '-', commit], {
      cwd: root, input: [...localSecrets].join('\n') + '\n', encoding: 'utf8', maxBuffer: 8 * 1024 * 1024,
    });
    if (result.status !== 0 && result.status !== 1) throw new Error('Git history scan failed.');
    for (const file of result.stdout.trim().split(/\r?\n/).filter(Boolean)) {
      findings.add(`history ${commit.slice(0, 12)}:${file.slice(commit.length + 1)}: contains a known credential; rotate it`);
    }
  }
}
console.log(`Scanned ${scanned} project text files; secret values are never displayed.`);
for (const finding of findings) console.log(finding);
for (const skippedPath of skippedPaths) console.log(`Could not inspect: ${skippedPath}`);
console.log(`Findings: ${findings.size}; unreadable directories: ${skippedPaths.length}`);
process.exitCode = findings.size || skippedPaths.length ? 1 : 0;

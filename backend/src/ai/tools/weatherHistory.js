/// Historical weather tool: Open-Meteo ERA5 reanalysis archive (keyless).
/// Source: https://archive-api.open-meteo.com (ERA5/ERA5-Land reanalysis).
/// Daily records are aggregated year by year so any range limit on a single
/// request never silently truncates the answer; missing years are reported.
/// Values are REANALYSIS GRID ESTIMATES, never claimed as station observations.
'use strict';

const axios = require('axios');
const fs = require('fs');
const path = require('path');

const ARCHIVE_URL = 'https://archive-api.open-meteo.com/v1/archive';
const CACHE_DIR = path.join(__dirname, '..', '..', 'data', 'cache');
const memCache = new Map(); // key -> { at, daily }
const MEM_TTL_MS = 24 * 60 * 60 * 1000;
const CURRENT_YEAR = new Date().getUTCFullYear();

let fetcher = null; // injectable for tests (defaults to axios.get)
function _fetch(url, opts) {
  return (fetcher || axios.get)(url, opts);
}
function _setFetcherForTests(fn) { fetcher = fn; }

function _round2(v) { return Math.round(v * 100) / 100; }

function cacheKey(lat, lon, year) {
  return `wx_${Number(lat).toFixed(3)}_${Number(lon).toFixed(3)}_${year}`;
}

function diskPath(key) { return path.join(CACHE_DIR, `${key}.json`); }

function readMem(key) {
  const e = memCache.get(key);
  if (!e) return null;
  if (Date.now() - e.at > MEM_TTL_MS) { memCache.delete(key); return null; }
  return e.daily;
}

function writeMem(key, daily) { memCache.set(key, { at: Date.now(), daily }); }

function readDisk(key) {
  try {
    const p = diskPath(key);
    if (!fs.existsSync(p)) return null;
    const raw = JSON.parse(fs.readFileSync(p, 'utf8'));
    if (!raw || !raw.daily || !raw.fetchedAt) return null;
    return raw.daily;
  } catch (_) { return null; }
}

function writeDisk(key, daily) {
  try {
    fs.mkdirSync(CACHE_DIR, { recursive: true });
    fs.writeFileSync(diskPath(key),
      JSON.stringify({ fetchedAt: new Date().toISOString(), daily }), 'utf8');
  } catch (_) { /* cache is best-effort only */ }
}

async function fetchYear(lat, lon, year) {
  const key = cacheKey(lat, lon, year);
  const cached = readMem(key) || readDisk(key);
  if (cached) return { year, daily: cached, fromCache: true };
  const url = `${ARCHIVE_URL}?latitude=${lat}&longitude=${lon}`
    + `&start_date=${year}-01-01&end_date=${year}-12-31`
    + '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=Asia%2FKolkata';
  const r = await _fetch(url, { timeout: 20000 });
  const d = r && r.data && r.data.daily ? r.data.daily : null;
  if (!d || !Array.isArray(d.time)) {
    throw new Error(`archive returned no daily series for ${year}`);
  }
  writeMem(key, d);
  writeDisk(key, d);
  return { year, daily: d, fromCache: false };
}

/**
 * Load daily archive data for [startYear..endYear] (chunked per year).
 * Returns { daily, yearsLoaded, missingYears, place } — missing years are
 * listed explicitly, never filled in.
 */
async function loadHistory({ lat, lon, startYear, endYear, concurrency }) {
  const lo = Math.max(1940, Math.floor(Number(startYear) || 2006));
  const hi = Math.min(CURRENT_YEAR, Math.floor(Number(endYear) || CURRENT_YEAR));
  const years = [];
  for (let y = lo; y <= hi; y++) years.push(y);
  const limit = Math.max(1, Math.min(6, Math.floor(Number(concurrency) || 4)));
  const daily = { time: [], temperature_2m_max: [], temperature_2m_min: [], precipitation_sum: [] };
  const yearsLoaded = [];
  const missingYears = [];
  for (let i = 0; i < years.length; i += limit) {
    const batch = years.slice(i, i + limit);
    const results = await Promise.all(batch.map(async (y) => {
      try {
        return await fetchYear(lat, lon, y);
      } catch (e) {
        return { year: y, error: String((e && e.message) || e) };
      }
    }));
    for (const r of results) {
      if (r.error || !r.daily) { missingYears.push(r.year); continue; }
      yearsLoaded.push(r.year);
      const t = r.daily.time || [];
      for (let k = 0; k < t.length; k++) {
        daily.time.push(t[k]);
        daily.temperature_2m_max.push((r.daily.temperature_2m_max || [])[k] ?? null);
        daily.temperature_2m_min.push((r.daily.temperature_2m_min || [])[k] ?? null);
        daily.precipitation_sum.push((r.daily.precipitation_sum || [])[k] ?? null);
      }
    }
  }
  yearsLoaded.sort((a, b) => a - b);
  missingYears.sort((a, b) => a - b);
  return {
    daily, yearsLoaded, missingYears, daysLoaded: daily.time.length,
    source: 'Open-Meteo Archive (ERA5 reanalysis)',
    kind: 'reanalysis_grid_estimate',
    fetchedAt: new Date().toISOString(),
  };
}

module.exports = { loadHistory, fetchYear, _setFetcherForTests, _round2, cacheKey, CURRENT_YEAR };
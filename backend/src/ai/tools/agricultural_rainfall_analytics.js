/// Deterministic rural analytics over retrieved records.
/// Every function is pure: same input -> same output (reproducible answers).
/// Missing observations are skipped, never treated as zero.
'use strict';

/** Annual precipitation totals (mm) from a daily series. */
function annualPrecipTotals(daily) {
  const byYear = new Map();
  const times = (daily && daily.time) || [];
  const precip = (daily && daily.precipitation_sum) || [];
  for (let i = 0; i < times.length; i++) {
    const v = precip[i];
    if (v === null || v === undefined || typeof v !== 'number' || Number.isNaN(v)) continue;
    const year = Number(String(times[i]).slice(0, 4));
    if (!Number.isFinite(year)) continue;
    byYear.set(year, (byYear.get(year) || 0) + v);
  }
  return [...byYear.entries()]
    .sort((a, b) => a[0] - b[0])
    .map(([year, mm]) => ({ year, mm: Math.round(mm * 10) / 10 }));
}

/** Monthly mean of a daily field across all loaded years (climatology). */
function monthlyClimatology(daily, field) {
  const sums = Array(12).fill(0);
  const counts = Array(12).fill(0);
  const times = (daily && daily.time) || [];
  const vals = (daily && daily[field]) || [];
  for (let i = 0; i < times.length; i++) {
    const v = vals[i];
    if (v === null || v === undefined || typeof v !== 'number' || Number.isNaN(v)) continue;
    const m = Number(String(times[i]).slice(5, 7)) - 1;
    if (m < 0 || m > 11) continue;
    sums[m] += v;
    counts[m] += 1;
  }
  return sums.map((s, idx) =>
    counts[idx] === 0 ? null : Math.round((s / counts[idx]) * 100) / 100);
}

function mean(nums) {
  const xs = (nums || []).filter((n) => typeof n === 'number' && Number.isFinite(n));
  if (xs.length === 0) return null;
  return Math.round((xs.reduce((a, b) => a + b, 0) / xs.length) * 100) / 100;
}

/** Ordinary-least-squares slope/intercept of y over x (e.g. mm per year). */
function linearTrend(pairs) {
  const pts = (pairs || []).filter((p) => Number.isFinite(p.x) && Number.isFinite(p.y));
  if (pts.length < 3) return null;
  const n = pts.length;
  const sx = pts.reduce((a, p) => a + p.x, 0);
  const sy = pts.reduce((a, p) => a + p.y, 0);
  const sxx = pts.reduce((a, p) => a + p.x * p.x, 0);
  const sxy = pts.reduce((a, p) => a + p.x * p.y, 0);
  const denom = n * sxx - sx * sx;
  if (denom === 0) return null;
  const slope = (n * sxy - sx * sy) / denom;
  const intercept = (sy - slope * sx) / n;
  return { slopePerUnit: Math.round(slope * 100) / 100, intercept: Math.round(intercept * 100) / 100, n };
}

/** Year-over-year changes; percent is null when the base year is 0. */
function yoyChanges(series) {
  const out = [];
  for (let i = 1; i < (series || []).length; i++) {
    const prev = series[i - 1];
    const cur = series[i];
    const pct = prev.mm === 0 ? null : Math.round(((cur.mm - prev.mm) / prev.mm) * 1000) / 10;
    out.push({ year: cur.year, changeMm: Math.round((cur.mm - prev.mm) * 10) / 10, changePct: pct });
  }
  return out;
}

/** Anomaly of a value against a baseline mean (absolute + percent). */
function anomaly(value, baselineMean) {
  if (!Number.isFinite(value) || !Number.isFinite(baselineMean) || baselineMean === 0) return null;
  return { abs: Math.round((value - baselineMean) * 10) / 10, pct: Math.round(((value - baselineMean) / baselineMean) * 1000) / 10 };
}

module.exports = { annualPrecipTotals, monthlyClimatology, mean, linearTrend, yoyChanges, anomaly };
/// Rural Intelligence answer engine: intent routing + evidence composition.
///
/// GOLDEN RULE: the response may reference ONLY tools that actually ran in
/// this request. Unrun tools, unqueried records and unconnected models are
/// described as unavailable, never as evidence.
'use strict';

const weatherHistory = require('./tools/weatherHistory');
const weatherForecast = require('./tools/weatherForecast');
const analytics = require('./tools/analytics');
const schemeData = require('../data/schemes');
const sourcesTool = require('./tools/sources');
const textModel = require('./adapters/textProvider');
const config = require('../config');

const DISCLAIMER_EN = 'AI-generated content can be wrong. Verify critical agronomic, legal or financial decisions with certified human experts.';
const DISCLAIMER_HI = 'AI se mili jaankari galat ho sakti hai. Khet, kanoon ya paise ke mahatvapurna faislon ke liye yogya visheshagya se jaanch karvayein.';

const RX = {
  price: /price|mandi|msp|bhav|भाव|कीमत|market rate|agmarknet|rate today|rate of/i,
  scheme: /scheme|yojana|योजना|subsid|loan|लोन|eligib|grant|scholarship|insurance|सरकारी|vishwakarma|mudra|kisan|fasal|pmjay|nsp\b/i,
  history: /histor|past|last\s+\d+|trend|climate|drought|सूखा|over the years|20\s*(year|साल)?|\d{4}\s*[-–]\s*\d{4}|पिछल|इतिहास/i,
  forecast: /forecast|today|tomorrow|now|current weather|this week|अगले|आज|कल|mausam/i,
  weather: /rain|temp|weather|मौसम|बारिश|तापमान|precip|heat|cold|monsoon/i,
};

/** Deterministic intent router. Precedence: price > scheme > weather-history > forecast > general. */
function routeIntent(query, categoryHint) {
  const q = String(query || '');
  const c = String(categoryHint || '').toLowerCase();
  if (c.includes('price') || c.includes('mandi')) return 'price';
  if (c.includes('scheme')) return 'scheme';
  if (c.includes('weather')) return RX.history.test(q) ? 'weather_history' : 'forecast';
  if (RX.price.test(q)) return 'price';
  if (RX.scheme.test(q)) return 'scheme';
  if (RX.history.test(q)) return (RX.weather.test(q) || /rain|temp|weather|climate|drought/i.test(q)) ? 'weather_history' : 'general';
  if (RX.forecast.test(q)) return 'forecast';
  if (RX.weather.test(q)) return 'forecast';
  return 'general';
}

const MONTHS_EN = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const MONTHS_HI = ['जन','फर','मार्च','अप्रै','मई','जून','जु','अग','सित','अक्ट','नव','दिस'];

/** Evidence-based templates. Only ever interpolated with tool outputs. */
function weatherHistoryAnswer({ place, years, meanMm, wet, dry, trend, wetMonthIdx, date, lang }) {
  const hi = String(lang || 'en').toLowerCase().startsWith('hi');
  const M = hi ? MONTHS_HI : MONTHS_EN;
  const trendTxt = trend == null
    ? (hi ? 'paryapt varshon ke record ke bina rujhan ki ganana nahi hui' : 'no trend computed (fewer than 3 complete years)')
    : (hi ? `rujhan ${trend > 0 ? '+' : ''}${trend} mm/varsh` : `trend ${trend > 0 ? '+' : ''}${trend} mm/year`);
  if (hi) {
    return `${place} — ${years[0]}–${years[years.length - 1]} ka varshik varsha record ` +
      `(Open-Meteo Archive, ERA5 punarvishleshan grid, prapt: ${date}): ausat ${meanMm} mm/varsh. ` +
      `Sabse geela varsh ${wet.year} (${wet.mm} mm), sabse sookha ${dry.year} (${dry.mm} mm). ${trendTxt}. ` +
      `Ausatan sabse geela mahina: ${M[wetMonthIdx]}. Ye model-grid anumaan hain, station maapan nahin.`;
  }
  return `${place} — annual rainfall ${years[0]}–${years[years.length - 1]} ` +
    `(source: Open-Meteo Archive, ERA5 reanalysis grid, retrieved ${date}): ` +
    `average ${meanMm} mm/year. Wettest year ${wet.year} (${wet.mm} mm); ` +
    `driest year ${dry.year} (${dry.mm} mm). ${trendTxt}. Wettest month on average: ${M[wetMonthIdx]}. ` +
    `These are modelled grid estimates, not a weather-station observation.`;
}

function forecastAnswer({ place, cur, todayMax, todayMin, todayPp, weekMax, date, lang }) {
  const hi = String(lang || 'en').toLowerCase().startsWith('hi');
  const now = `, ${cur.temp} degC, humidity ${cur.rh}%, wind ${cur.wind} km/h`;
  if (hi) {
    return `${place} — vartaman mausam${now}. Aaj: adhiktam ${todayMax} degC, nyuntam ${todayMin} degC, ` +
      `varsha sambhavna ${todayPp}%. Agle 7 din ka adhiktam tapmaan ~${weekMax} degC tak. ` +
      `Ye NWP model purvanumaan hai (prapt: ${date}), guarantee nahin — aapda sthiti me sthaniya prashasan ke nirdesh maanein.`;
  }
  return `${place} — current conditions${now}. Today: high ${todayMax} C, low ${todayMin} C, ` +
    `precipitation probability ${todayPp}%. The coming 7 days reach highs around ${weekMax} C. ` +
    `This is an NWP model forecast (retrieved ${date}), not a guarantee — follow local authorities in emergencies.`;
}
/** Resolve query location: explicit lat/lon wins; otherwise pilot default. */
function resolveLocation(location) {
  const lat = Number(location && location.lat);
  const lon = Number(location && location.lon);
  if (Number.isFinite(lat) && lat >= -90 && lat <= 90 &&
      Number.isFinite(lon) && lon >= -180 && lon <= 180) {
    return { lat, lon, name: (location && location.name) || `${lat}, ${lon}` };
  }
  return { lat: Number(config.defaultLatitude), lon: Number(config.defaultLongitude), name: 'pilot area (Gujarat default)' };
}

function base(lang) {
  const hi = String(lang || 'en').toLowerCase().startsWith('hi');
  return {
    ok: true, intent: 'general', answer: '', sources: [], figures: [],
    calculations: [], warnings: [], confidence: 'moderate', dataPeriod: null,
    series: null, toolsRun: [],
    capability: { textModel: textModel.configured(), visionModel: false },
    disclaimer: hi ? DISCLAIMER_HI : DISCLAIMER_EN,
  };
}

function srcFetchDate() { return new Date().toISOString().slice(0, 10); }

async function runWeatherHistory({ loc, lang }) {
  const res = base(lang);
  res.intent = 'weather_history';
  const hist = await weatherHistory.loadHistory({ lat: loc.lat, lon: loc.lon, startYear: 2006, endYear: weatherHistory.CURRENT_YEAR - 1 });
  res.toolsRun.push('weatherHistory.loadHistory');
  const totals = analytics.annualPrecipTotals(hist.daily);
  res.toolsRun.push('analytics.annualPrecipTotals');
  if (totals.length === 0) {
    res.ok = false;
    res.answer = 'No usable annual rainfall records were returned for this location and period. No analysis was computed.';
    res.confidence = 'low';
    res.warnings.push('Archive returned zero usable daily records: check connectivity and retry.');
    return res;
  }
  const yrs = totals.map((t) => t.year);
  const m = analytics.mean(totals.map((t) => t.mm));
  res.toolsRun.push('analytics.mean');
  const wet = totals.reduce((a, b) => (b.mm > a.mm ? b : a));
  const dry = totals.reduce((a, b) => (b.mm < a.mm ? b : a));
  const tr = analytics.linearTrend(totals.map((t) => ({ x: t.year, y: t.mm })));
  res.toolsRun.push('analytics.linearTrend');
  const clim = analytics.monthlyClimatology(hist.daily, 'precipitation_sum');
  let wetMonthIdx = 6;
  let best = -1;
  for (let i = 0; i < 12; i++) {
    if (clim[i] != null && clim[i] > best) { best = clim[i]; wetMonthIdx = i; }
  }
  res.answer = weatherHistoryAnswer({ place: loc.name, years: yrs, meanMm: m, wet, dry, trend: tr ? tr.slopePerUnit : null, wetMonthIdx, date: srcFetchDate(), lang });
  res.figures = [
    { label: 'Annual mean rainfall', value: m, unit: 'mm/year', period: `${yrs[0]}-${yrs[yrs.length - 1]}`, kind: 'calculated' },
    { label: `Wettest year (${wet.year})`, value: wet.mm, unit: 'mm', period: `${wet.year}`, kind: 'calculated' },
    { label: `Driest year (${dry.year})`, value: dry.mm, unit: 'mm', period: `${dry.year}`, kind: 'calculated' },
  ];
  if (tr) {
    res.figures.push({ label: 'Linear trend', value: tr.slopePerUnit, unit: 'mm/year', period: `${yrs[0]}-${yrs[yrs.length - 1]}`, kind: 'calculated' });
    res.calculations.push({ formula: 'annual_mm = SUM(daily precipitation_sum per year)', description: 'Missing days are skipped, never zero-filled.' });
    res.calculations.push({ formula: 'trend = OLS slope of annual_mm on year', description: `Least-squares fit over n=${tr.n} years; descriptive only, not a forecast.` });
  }
  res.series = { indicator: 'precipitation_annual_mm', unit: 'mm', points: totals };
  res.dataPeriod = { from: `${yrs[0]}-01-01`, to: `${yrs[yrs.length - 1]}-12-31` };
  res.sources = [{ title: 'Open-Meteo Historical Archive (ERA5 reanalysis)', url: 'https://open-meteo.com/', retrievedAt: hist.fetchedAt, type: 'reanalysis grid estimate' }];
  res.warnings.push('Reanalysis grid estimate, not a local weather-station observation.');
  if (hist.missingYears.length > 0) {
    res.warnings.push(`Missing years excluded from all figures: ${hist.missingYears.join(', ')}.`);
  }
  return res;
}

async function runForecast({ loc, lang }) {
  const res = base(lang);
  res.intent = 'forecast';
  let fc;
  try {
    fc = await weatherForecast.getForecast({ lat: loc.lat, lon: loc.lon });
  } catch (e) {
    res.ok = false;
    res.answer = 'The forecast service could not be reached. No forecast is reported.';
    res.confidence = 'low';
    res.toolsRun.push('weatherForecast.getForecast:FAILED');
    res.warnings.push('Upstream forecast unreachable: check connectivity and retry.');
    return res;
  }
  res.toolsRun.push('weatherForecast.getForecast');
  const cur = fc.current || {};
  const d = fc.daily || {};
  const tmax = (d.temperature_2m_max || [])[0];
  const tmin = (d.temperature_2m_min || [])[0];
  const pp = (d.precipitation_probability_max || [])[0];
  const highs = (d.temperature_2m_max || []).filter((n) => typeof n === 'number');
  const weekMax = highs.length ? Math.max(...highs) : null;
  const entry = (v) => (typeof v === 'number' ? v : 'not reported');
  res.answer = forecastAnswer({
    place: loc.name,
    cur: { temp: entry(cur.temperature_2m), rh: entry(cur.relative_humidity_2m), wind: entry(cur.wind_speed_10m) },
    todayMax: entry(tmax), todayMin: entry(tmin), todayPp: entry(pp), weekMax: entry(weekMax),
    date: srcFetchDate(), lang,
  });
  res.figures = [
    { label: 'Current temperature', value: typeof cur.temperature_2m === 'number' ? cur.temperature_2m : null, unit: 'degC', period: 'now', kind: 'observed' },
    { label: 'Today high / low', value: null, unit: 'degC', period: 'today', kind: 'model_forecast' },
  ];
  res.series = { indicator: 'temperature_2m_max_7day', unit: 'degC', points: (d.time || []).map((t, i) => ({ date: t, value: (d.temperature_2m_max || [])[i] ?? null })) };
  res.dataPeriod = { from: (d.time || [])[0] || null, to: (d.time || [])[((d.time || []).length - 1)] || null };
  res.sources = [{ title: 'Open-Meteo Forecast (NWP models)', url: 'https://open-meteo.com/', retrievedAt: fc.fetchedAt, type: 'model forecast' }];
  res.warnings.push('Model forecast valid for its issue period only; not a guarantee.');
  return res;
}

async function runPrice({ query = '', lang, fetcher = require('../routes/mandiRoutes').fetchPrices }) {
  const res = base(lang);
  res.intent = 'price';
  const commodities = ['wheat', 'rice', 'paddy', 'maize', 'cotton', 'onion', 'potato', 'tomato', 'soyabean', 'groundnut', 'mustard', 'gram'];
  const commodity = commodities.find((name) => new RegExp(`\\b${name}\\b`, 'i').test(query));
  try {
    const payload = await fetcher({ limit: 50, offset: 0, ...(commodity ? { commodity } : {}) });
    res.toolsRun.push('mandi.fetchPrices');
    const records = (payload.records || []).filter((row) => Number.isFinite(Number(row.modal_price))).slice(0, 5);
    if (!records.length) {
      res.answer = 'No reported mandi prices matched this query in the current government dataset response. Try another commodity or the Mandi screen.';
      res.confidence = 'low';
    } else {
      res.answer = records.map((row) => `${row.commodity} at ${row.market}, ${row.state}: modal INR ${row.modal_price}/quintal (reported ${row.arrival_date || 'date unavailable'}).`).join(' ');
      res.figures = records.map((row) => ({ label: `${row.commodity} - ${row.market}`, value: Number(row.modal_price), unit: 'INR/quintal', period: row.arrival_date || 'not supplied', kind: 'reported_price' }));
    }
    res.sources = [{ title: 'Open Government Data Platform India - daily mandi prices', url: payload.source, retrievedAt: payload.last_synced_at, type: 'government reported market data' }];
    res.dataPeriod = { from: records[0]?.arrival_date || null, to: records[0]?.arrival_date || null };
    res.warnings.push('These are reported daily market prices, not real-time trades. Verify date, grade and variety before deciding.');
  } catch (_) {
    res.toolsRun.push('mandi.fetchPrices:FAILED');
    res.ok = false;
    res.answer = 'Government mandi price data is temporarily unavailable. No price is reported.';
    res.confidence = 'low';
    res.warnings.push('The government data request failed or the provider key is missing.');
  }
  return res;
}

function runScheme({ query, lang }) {
  const res = base(lang);
  res.intent = 'scheme';
  const matches = schemeData.searchSchemes(query, 5);
  res.toolsRun.push('schemeData.searchSchemes');
  if (matches.length === 0) {
    res.answer = 'No scheme in the in-app catalog matched that query. Try a scheme name (e.g. PM-KISAN), a topic (loan, insurance, artisan), or open the Schemes section of the app.';
    res.confidence = 'low';
    res.warnings.push('Catalog search only; no records retrieved.');
    return res;
  }
  const lines = matches.map((r, i) =>
    `${i + 1}. ${r.scheme.name} — ${r.scheme.description} Eligibility: ${r.scheme.eligibility}. Department: ${r.scheme.department}.`);
  const hi = String(lang || 'en').toLowerCase().startsWith('hi');
  res.answer = (hi ? 'In-app catalog me ye yojanaen mili: ' : 'Schemes found in the in-app catalog: ') + lines.join(' ') +
    (hi
      ? ' Labh, dastavej, samay-seema official portal par jaanchein — catalog ke niyam antim nahin hain.'
      : ' Verify benefits, documents and deadlines on the official portal — catalog rules are not final.');
  res.figures = matches.map((r) => ({
    label: `${r.scheme.name} (dept processing)`, value: r.scheme.processingDays, unit: 'working days (in-app catalog)', period: 'catalog', kind: 'app_record',
  }));
  res.sources = matches.filter((r) => r.scheme.portal).map((r) => ({
    title: `${r.scheme.name} — official portal`, url: r.scheme.portal, retrievedAt: srcFetchDate(), type: 'official portal (rules not re-verified here)',
  }));
  res.sources.push({ title: 'National Portal of India (reach any ministry)', url: 'https://www.india.gov.in/', retrievedAt: srcFetchDate(), type: 'official directory (not queried)' });
  res.warnings.push('Catalog eligibility/deadlines may be outdated: confirm on the official portal before applying. Approval is never guaranteed.');
  return res;
}

async function runGeneral({ query, history, lang, location, category }) {
  const res = base(lang);
  res.intent = 'general';
  const vars = {
    location: location && location.name ? location.name : 'not provided',
    language: lang || 'en',
    tools: 'No live tools were called for this general answer. Weather, mandi prices and schemes are separate routed intents.',
  };
  if (textModel.configured()) {
    const histMsgs = (history || []).slice(-6).map((h) => ({
      role: 'user', content: `Q: ${h.q || ''}\nA (previous): ${(h.a || '').slice(0, 500)}`,
    }));
    const text = await textModel.generate({
      systemVars: vars,
      messages: [...histMsgs, { role: 'user', content: String(query || '') }],
    });
    res.toolsRun.push(text ? 'textModel.generate:OK' : 'textModel.generate:FAILED');
    if (text) {
      res.answer = text;
      res.warnings.push('Composed by the configured text model from its own knowledge: verify critical claims on official sources.');
      return res;
    }
  }
  res.toolsRun.push(textModel.configured() ? 'textModel:unavailable' : 'textModel:not_configured');
  const hi = String(lang || 'en').toLowerCase().startsWith('hi');
  res.answer = hi
    ? 'Is samay bhasha-model se uttar nahin mila aur koi satyapit record match nahin hua. Kripya baad mein phir koshish karein.'
    : 'The language model did not provide an answer, and no verified record matched this query. Please try again later.';
  res.sources = [
    { title: 'ICAR (agronomic research, official)', url: 'https://icar.gov.in/', retrievedAt: srcFetchDate(), type: 'official reference (not queried)' },
    { title: 'Ministry of Agriculture & Farmers Welfare', url: 'https://agriwelfare.gov.in/', retrievedAt: srcFetchDate(), type: 'official reference (not queried)' },
    { title: 'Open Government Data Platform India', url: 'https://www.data.gov.in/', retrievedAt: srcFetchDate(), type: 'official reference (API key required; not queried)' },
  ];
  res.confidence = 'low';
  res.warnings.push('No model output and no retrieved record: this response is a capability statement, not an answer.');
  return res;
}

/** Main entry: routes intent, runs exactly the needed tools, composes evidence. */
async function answer(input) {
  const query = String((input && input.query) || '').slice(0, 2000);
  const lang = String((input && input.language) || 'en');
  const loc = resolveLocation(input && input.location);
  const category = (input && input.category) || null;
  const history = Array.isArray(input && input.history) ? input.history.slice(-6) : [];
  if (!query.trim()) {
    const res = base(lang);
    res.ok = false;
    res.answer = 'Empty query: nothing was searched and no tools ran.';
    res.confidence = 'low';
    return res;
  }
  const intent = routeIntent(query, category);
  if (intent === 'weather_history') return runWeatherHistory({ loc, lang });
  if (intent === 'forecast') return runForecast({ loc, lang });
  if (intent === 'price') return runPrice({ query, lang });
  if (intent === 'scheme') return runScheme({ query, lang });
  return runGeneral({ query, history, lang, location: loc, category });
}

module.exports = { answer, routeIntent, resolveLocation, runGeneral, runScheme, runPrice, runForecast, runWeatherHistory };

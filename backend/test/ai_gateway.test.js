/// Rural Intelligence gateway tests (node:test, built-in — no extra deps).
/// All analytics/routing/vision tests are fixture-driven (no network).
/// Network-touching paths are covered via injected fetchers/mocks.
'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');

const analytics = require('../src/ai/tools/analytics');
const schemeData = require('../src/data/schemes');
const sourcesTool = require('../src/ai/tools/sources');
const engine = require('../src/ai/answerEngine');
const textModel = require('../src/ai/adapters/textModel');
const visionModel = require('../src/ai/adapters/visionModel');
const weatherHistory = require('../src/ai/tools/weatherHistory');

describe('analytics (pure, reproducible)', () => {
  it('annualPrecipTotals sums daily values per year and skips missing (!= 0)', () => {
    const daily = {
      time: ['2020-01-01', '2020-06-01', '2021-01-01'],
      precipitation_sum: [10, null, 0.5],
    };
    assert.deepEqual(analytics.annualPrecipTotals(daily), [
      { year: 2020, mm: 10 }, { year: 2021, mm: 0.5 },
    ]);
  });
  it('linearTrend returns OLS slope', () => {
    const tr = analytics.linearTrend([
      { x: 2000, y: 100 }, { x: 2001, y: 110 }, { x: 2002, y: 120 },
    ]);
    assert.equal(tr.slopePerUnit, 10);
    assert.equal(analytics.linearTrend([{ x: 1, y: 1 }]), null);
  });
  it('anomaly guards zero baseline', () => {
    assert.equal(analytics.anomaly(5, 0), null);
    assert.deepEqual(analytics.anomaly(110, 100), { abs: 10, pct: 10 });
  });
  it('yoyChanges handles zero base', () => {
    const out = analytics.yoyChanges([{ year: 1, mm: 0 }, { year: 2, mm: 5 }]);
    assert.deepEqual(out, [{ year: 2, changeMm: 5, changePct: null }]);
  });
});

describe('intent router', () => {
  it('routes price/scheme/history/forecast/general in precedence order', () => {
    assert.equal(engine.routeIntent('mandi price of wheat today'), 'price');
    assert.equal(engine.routeIntent('pm kisan yojana eligibility'), 'scheme');
    assert.equal(engine.routeIntent('rainfall last 20 years'), 'weather_history');
    assert.equal(engine.routeIntent('weather today'), 'forecast');
    assert.equal(engine.routeIntent('तापमान'), 'forecast');
    assert.equal(engine.routeIntent('भाव'), 'price');
    assert.equal(engine.routeIntent('hello there'), 'general');
    assert.equal(engine.routeIntent('', 'schemes'), 'scheme');
    assert.equal(engine.routeIntent('', 'weather'), 'forecast');
    assert.equal(engine.routeIntent('20 years drought'), 'weather_history');
  });
  it('rejects empty queries without running tools', async () => {
    const r = await engine.answer({ query: '   ' });
    assert.equal(r.ok, false);
    assert.deepEqual(r.toolsRun, []);
  });
});

describe('scheme retrieval (verified in-app dataset)', () => {
  it('finds PM-KISAN by name and ranks it first', () => {
    const hits = schemeData.searchSchemes('pm-kisan', 3);
    assert.ok(hits.length > 0);
    assert.equal(hits[0].scheme.id, 'pm-kisan');
  });
  it('finds loan schemes by topic', () => {
    const hits = schemeData.searchSchemes('micro loan business', 5);
    assert.ok(hits.some((h) => h.scheme.id === 'pm-mudra'));
  });
  it('returns [] for empty queries', () => {
    assert.deepEqual(schemeData.searchSchemes('  '), []);
  });
});

describe('price intent is honest (no live source)', () => {
  it('reports no price and forces a warning', () => {
    const r = engine.runPrice({ lang: 'en' });
    assert.equal(r.intent, 'price');
    assert.deepEqual(r.figures, []);
    assert.ok(r.warnings.some((w) => /no verified price source/i.test(w)));
    assert.ok(r.answer.includes('agmarknet.gov.in'));
    assert.ok(r.sources.length >= 2);
  });
});

describe('Gemini exclusion guard', () => {
  it('textModel rejects Gemini endpoints even if configured', () => {
    assert.equal(textModel.geminiGuard('https://generativelanguage.googleapis.com/v1beta/models'), true);
    assert.equal(textModel.geminiGuard('https://api.groq.com/openai/v1'), false);
    assert.equal(textModel.geminiGuard(''), false);
  });
  it('textModel is unconfigured without env', () => {
    delete process.env.LLM_BASE_URL;
    delete process.env.LLM_MODEL;
    assert.equal(textModel.configured(), false);
    assert.match(textModel.capabilities().reason, /not set/);
  });
});

describe('vision input validation', () => {
  it('rejects missing/foreign/oversize payloads', () => {
    assert.match(visionModel.validateInput({ imageBase64: '', mimeType: 'image/jpeg' }), /No image data/);
    assert.match(visionModel.validateInput({ imageBase64: 'aGVsbG8=', mimeType: 'image/gif' }), /Unsupported/);
    assert.match(
      visionModel.validateInput({ imageBase64: 'a'.repeat(visionModel.MAX_B64_CHARS + 1), mimeType: 'image/png' }),
      /too large/);
  });
  it('reports honest not-configured when no vision model is set', async () => {
    delete process.env.VISION_BASE_URL;
    delete process.env.VISION_MODEL;
    const r = await visionModel.analyze({ imageBase64: 'aGVsbG8=', mimeType: 'image/jpeg' });
    assert.equal(r.ok, false);
    assert.equal(r.status, 'vision_model_not_configured');
    assert.equal(r.observation, null);
  });
});

describe('weather history (injected fetcher, no network)', () => {
  it('aggregates one year and reports coverage', async () => {
    // Year-aware mock: every requested year returns its own 2-day fixture
    // (2 mm on Jan 1, missing on Jan 2) so totals stay 2 mm/year.
    weatherHistory._setFetcherForTests(async (url) => {
      const m = /start_date=(\d{4})-01-01/.exec(String(url || ''));
      const y = m ? m[1] : '2020';
      return {
        data: {
          daily: {
            time: [`${y}-01-01`, `${y}-01-02`],
            temperature_2m_max: [30, 31],
            temperature_2m_min: [20, 21],
            precipitation_sum: [2, null],
          },
        },
      };
    });
    try {
      const r = await engine.runWeatherHistory({
        loc: { lat: 11.111, lon: 22.222, name: 'test site' }, lang: 'en',
      });
      assert.equal(r.ok, true);
      assert.equal(r.intent, 'weather_history');
      assert.ok(r.answer.includes('2 mm'));
      assert.ok(r.toolsRun.includes('analytics.annualPrecipTotals'));
      assert.ok(r.sources.some((s) => /open-meteo/i.test(s.title)));
      assert.ok(r.figures.length >= 3);
    } finally {
      weatherHistory._setFetcherForTests(null);
    }
  });
});

describe('sources registry', () => {
  it('marks prices as blocked (no invented endpoints)', () => {
    const priceSources = sourcesTool.sourcesByKind('prices');
    assert.ok(priceSources.length >= 2);
    for (const s of priceSources) {
      assert.notEqual(s.status, 'connected');
      assert.ok(/^https:\/\//.test(s.url));
    }
  });
});
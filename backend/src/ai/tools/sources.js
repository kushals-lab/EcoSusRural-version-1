/// Verified source registry for the Rural Intelligence gateway.
/// status: connected (actually callable here) | reference (official link only,
/// no API access from this deployment) | blocked (needs key/registration).
/// Nothing here invents endpoints, dataset ids or auth methods.
'use strict';

const SOURCES = [
  { id: 'openmeteo-archive', name: 'Open-Meteo Historical Archive (ERA5 reanalysis)',
    url: 'https://open-meteo.com/', status: 'connected', auth: 'none (keyless)',
    license: 'CC BY 4.0', coverage: '1940-present daily grid', kind: 'weather history' },
  { id: 'openmeteo-forecast', name: 'Open-Meteo Forecast (NWP models)',
    url: 'https://open-meteo.com/', status: 'connected', auth: 'none (keyless)',
    license: 'CC BY 4.0', coverage: 'current + 7-16 days', kind: 'weather forecast' },
  { id: 'app-schemes', name: 'EcoSusRural in-app scheme catalog',
    url: null, status: 'connected', auth: 'none',
    license: 'internal app content', coverage: '11 records, eligibility + portals', kind: 'schemes' },
  { id: 'imd', name: 'India Meteorological Department',
    url: 'https://mausam.imd.gov.in/', status: 'reference', auth: 'n/a',
    license: 'official', coverage: 'station observations, advisories', kind: 'weather' },
  { id: 'agmarknet', name: 'AGMARKNET (DAC&FW mandi prices)',
    url: 'https://agmarknet.gov.in/', status: 'blocked', auth: 'no keyless official API; registered access only',
    license: 'official', coverage: 'mandi arrivals/prices', kind: 'prices' },
  { id: 'enam', name: 'e-NAM',
    url: 'https://www.enam.gov.in/', status: 'blocked', auth: 'no keyless official API',
    license: 'official', coverage: 'online mandi trade', kind: 'prices' },
  { id: 'datagovin', name: 'Open Government Data Platform India',
    url: 'https://www.data.gov.in/', status: 'blocked', auth: 'API key registration required',
    license: 'per-resource (GODL mostly)', coverage: 'cross-sector datasets', kind: 'open data' },
  { id: 'icar', name: 'ICAR / Krishi Vigyan Kendras',
    url: 'https://icar.gov.in/', status: 'reference', auth: 'n/a',
    license: 'official', coverage: 'agronomic research, advisories', kind: 'agriculture' },
  { id: 'agriwelfare', name: 'Ministry of Agriculture & Farmers Welfare',
    url: 'https://agriwelfare.gov.in/', status: 'reference', auth: 'n/a',
    license: 'official', coverage: 'programs, statistics', kind: 'agriculture' },
];

function sourcesByKind(kind) {
  return SOURCES.filter((s) => s.kind === kind);
}

module.exports = { SOURCES, sourcesByKind };
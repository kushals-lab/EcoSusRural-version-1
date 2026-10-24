const axios = require('axios');
const catalog = require('../data/verified_scheme_links.json');
const checks = new Map();
const allowedHosts = new Set(catalog.flatMap(r => [r.official_information_url, r.official_application_url]).filter(Boolean).map(s => new URL(s).hostname));
function validUrl(raw) {
  try { const u = new URL(raw); return u.protocol === 'https:' && !u.username && !u.password && allowedHosts.has(u.hostname); }
  catch (_) { return false; }
}
async function checkLinks() {
  for (const item of catalog) {
    const url = item.official_application_url || item.official_information_url;
    if (!validUrl(url)) continue;
    try {
      // Never follow redirects to an unreviewed site or equate HTTP 200 with an open window.
      const result = await axios.get(url, {timeout: 10000, maxRedirects: 0, maxContentLength: 1000000,
        validateStatus: s => s >= 200 && s < 500});
      checks.set(item.id, {link_status: result.status, link_checked_at: new Date().toISOString()});
    } catch (_) { checks.set(item.id, {link_status: null, link_checked_at: new Date().toISOString()}); }
  }
}
if (process.env.SCHEME_LINK_CHECKS === 'true') {
  void checkLinks(); setInterval(checkLinks, 86400000).unref();
}
module.exports = {catalog, checks, validUrl, checkLinks};

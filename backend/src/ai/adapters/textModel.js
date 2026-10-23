/// Provider-neutral TEXT/REASONING model adapter (OpenAI-compatible chat).
///
/// WORKS WITH (when configured via env): any OpenAI-compatible /chat/completions
/// endpoint — e.g. self-hosted Ollama/vLLM, Mistral, Groq, Together, custom.
///
/// HARD RULES (per migration spec):
///  - No Gemini adapter exists and one must never be added here.
///  - Any base URL pointing at generativelanguage.googleapis.com (or any host
///    containing the token "gemini") is REJECTED with a config error and is
///    never called. There is no hidden fallback to Gemini anywhere.
'use strict';

const axios = require('axios');
const fs = require('fs');
const path = require('path');

function settings() {
  return {
    baseUrl: (process.env.LLM_BASE_URL || '').trim().replace(/\/$/, ''),
    apiKey: (process.env.LLM_API_KEY || '').trim(),
    model: (process.env.LLM_MODEL || '').trim(),
  };
}

function geminiGuard(url) {
  return /generativelanguage|gemini/i.test(String(url || ''));
}

function configured() {
  const s = settings();
  return s.baseUrl.length > 0 && s.model.length > 0 && !geminiGuard(s.baseUrl);
}

function capabilities() {
  const s = settings();
  if (!s.baseUrl || !s.model) {
    return { textModel: false, reason: 'LLM_BASE_URL/LLM_MODEL not set' };
  }
  if (geminiGuard(s.baseUrl)) {
    return { textModel: false, reason: 'rejected: Gemini endpoints are forbidden by project policy' };
  }
  return { textModel: true, reason: `model=${s.model}` };
}

let systemPromptCache = null;
function loadSystemPrompt() {
  if (systemPromptCache !== null) return systemPromptCache;
  try {
    systemPromptCache = fs.readFileSync(
      path.join(__dirname, '..', 'prompts', 'system_prompt.md'), 'utf8');
  } catch (_) { systemPromptCache = ''; }
  return systemPromptCache;
}

function fillPrompt(tpl, vars) {
  return String(tpl || '')
    .replace('{{user_location_if_available}}', vars.location || 'not provided')
    .replace('{{preferred_language_if_available}}', vars.language || 'not provided')
    .replace('{{current_datetime}}', new Date().toISOString())
    .replace('{{tool_descriptions}}', vars.tools || 'no tools connected');
}

/**
 * OpenAI-compatible chat completion. Returns text on success, null on any
 * failure (caller falls back to retrieval-only answers — never fabricated).
 */
async function generate({ systemVars, messages, maxTokens }) {
  const s = settings();
  if (!s.baseUrl || !s.model || geminiGuard(s.baseUrl)) return null;
  try {
    const system = fillPrompt(loadSystemPrompt(), systemVars || {});
    const r = await axios.post(`${s.baseUrl}/chat/completions`, {
      model: s.model,
      messages: [
        ...(system ? [{ role: 'system', content: system }] : []),
        ...(messages || []),
      ],
      temperature: 0.3,
      max_tokens: Math.max(64, Math.min(2048, Number(maxTokens) || 1024)),
    }, {
      headers: {
        'Content-Type': 'application/json',
        ...(s.apiKey ? { Authorization: `Bearer ${s.apiKey}` } : {}),
      },
      timeout: 45000,
    });
    const text = r && r.data && r.data.choices &&
      r.data.choices[0] && r.data.choices[0].message &&
      r.data.choices[0].message.content;
    const t = String(text || '').trim();
    return t.length > 0 ? t : null;
  } catch (_) { return null; }
}

module.exports = { configured, capabilities, generate, geminiGuard, settings };
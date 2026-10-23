/// Vision adapter (image understanding via OpenAI-compatible chat with images).
/// Same policy as textModel: NEVER Gemini; nothing stored (no fs writes, no
/// payload logging — base64 is held in memory only for the single request).
'use strict';

const axios = require('axios');

const MIME_OK = new Set(['image/jpeg', 'image/png', 'image/webp']);
const MAX_B64_CHARS = 240000; // fits the global 256kb JSON body budget

function settings() {
  return {
    baseUrl: (process.env.VISION_BASE_URL || '').trim().replace(/\/$/, ''),
    apiKey: (process.env.VISION_API_KEY || '').trim(),
    model: (process.env.VISION_MODEL || '').trim(),
  };
}

function configured() {
  const s = settings();
  return s.baseUrl.length > 0 && s.model.length > 0 &&
    !/generativelanguage|gemini/i.test(s.baseUrl);
}

function validateInput({ imageBase64, mimeType }) {
  if (typeof imageBase64 !== 'string' || imageBase64.length === 0) {
    return 'No image data was provided.';
  }
  if (!MIME_OK.has(String(mimeType || '').toLowerCase())) {
    return 'Unsupported image format. Use JPEG, PNG, or WebP.';
  }
  if (imageBase64.length > MAX_B64_CHARS) {
    return 'Image is too large for the API payload budget (downscale and retry).';
  }
  if (!/^[A-Za-z0-9+\/=\s]+$/.test(imageBase64.slice(0, 4096))) {
    return 'Image data does not look like valid base64.';
  }
  return null;
}

async function analyze({ imageBase64, mimeType, question }) {
  const s = settings();
  if (!configured()) {
    return {
      ok: false, status: 'vision_model_not_configured',
      observation: null,
      message: 'No image-understanding model is connected to this deployment ' +
        '(VISION_BASE_URL/VISION_MODEL are unset). The upload pipeline works; ' +
        'point it at any non-Gemini OpenAI-compatible vision endpoint (e.g. a ' +
        'self-hosted model) to enable real analysis. No analysis was performed.',
    };
  }
  try {
    const r = await axios.post(`${s.baseUrl}/chat/completions`, {
      model: s.model,
      messages: [{
        role: 'user',
        content: [
          { type: 'text', text: String(question || 'Describe what is visible and note any plant/livestock/machinery concerns.') },
          { type: 'image_url', image_url: { url: `data:${mimeType};base64,${imageBase64}` } },
        ],
      }],
      temperature: 0.2,
      max_tokens: 1024,
    }, {
      headers: {
        'Content-Type': 'application/json',
        ...(s.apiKey ? { Authorization: `Bearer ${s.apiKey}` } : {}),
      },
      timeout: 60000,
    });
    const text = r && r.data && r.data.choices &&
      r.data.choices[0] && r.data.choices[0].message &&
      r.data.choices[0].message.content;
    const t = String(text || '').trim();
    if (!t) {
      return { ok: false, status: 'vision_empty_result', observation: null,
        message: 'The vision model returned an empty result; no analysis available.' };
    }
    return { ok: true, status: 'analyzed', observation: t, message: t };
  } catch (_) {
    return { ok: false, status: 'vision_model_unreachable', observation: null,
      message: 'The configured vision model could not be reached; no analysis was performed.' };
  }
}

module.exports = { configured, validateInput, analyze, settings, MIME_OK, MAX_B64_CHARS };
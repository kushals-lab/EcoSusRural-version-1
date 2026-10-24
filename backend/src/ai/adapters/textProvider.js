// Server-side text generation. Provider credentials never enter the Flutter app.
'use strict';

const axios = require('axios');
const openAiCompatible = require('./textModel');

function geminiKeys() {
  return [...new Set((process.env.GEMINI_API_KEYS || process.env.GEMINI_API_KEY || '')
    .split(',').map((key) => key.trim()).filter(Boolean))];
}

function geminiModel() {
  const model = process.env.GEMINI_MODEL || 'gemini-3-flash-preview';
  return /^[a-zA-Z0-9_.-]+$/.test(model) ? model : 'gemini-3-flash-preview';
}

function configured() {
  return geminiKeys().length > 0 || openAiCompatible.configured();
}

function capabilities() {
  if (geminiKeys().length) return { textModel: true, provider: 'Gemini', model: geminiModel() };
  return openAiCompatible.capabilities();
}

async function generate({ systemVars = {}, messages = [], maxTokens = 1024 }) {
  const keys = geminiKeys();
  if (!keys.length) return openAiCompatible.generate({ systemVars, messages, maxTokens });

  const system = [
    'You are EcoSusRural AI, a practical rural knowledge assistant.',
    'Answer in the preferred language when possible. Be concise and state uncertainty.',
    'No live tools or records were queried for this general question. Do not invent current prices, weather, citations, links, or verified diagnoses.',
    'For hazardous agricultural treatment, medical, legal, or financial decisions, advise verification with qualified local experts.',
    `Location: ${String(systemVars.location || 'not supplied').slice(0, 200)}.`,
    `Preferred language: ${String(systemVars.language || 'en').slice(0, 40)}.`,
  ].join(' ');
  const context = messages.slice(-7).map((message) =>
    `${message.role === 'assistant' ? 'Assistant' : 'User'}: ${String(message.content || '').slice(0, 2000)}`,
  ).join('\n');
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel()}:generateContent`;
  for (const key of keys) {
    try {
      const response = await axios.post(url, {
        systemInstruction: { parts: [{ text: system }] },
        contents: [{ role: 'user', parts: [{ text: context }] }],
        generationConfig: { temperature: 0.3, maxOutputTokens: Math.max(64, Math.min(2048, Number(maxTokens) || 1024)) },
      }, { headers: { 'Content-Type': 'application/json', 'x-goog-api-key': key }, timeout: 30000 });
      const answer = response.data?.candidates?.[0]?.content?.parts?.map((part) => part.text || '').join('').trim();
      return answer || null;
    } catch (error) {
      // A distinct second key may recover from a quota or key-specific failure.
      if (![401, 403, 429].includes(error.response?.status)) return null;
    }
  }
  return null;
}

module.exports = { configured, capabilities, generate, geminiKeys, geminiModel };

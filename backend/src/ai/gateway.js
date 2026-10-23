/// Rural Intelligence AI gateway — provider-independent, NO Gemini dependency.
///
/// Routes:
///   POST /api/ai/answer       {query, category?, history?, location?, language?}
///   POST /api/ai/image        {imageBase64, mimeType, question?, language?}
///   GET  /api/ai/capabilities
///
/// Media policy: payloads are validated (type/size) and held in memory only
/// for the single request — never written to disk, never logged.
'use strict';

const express = require('express');
const rateLimit = require('express-rate-limit');
const answerEngine = require('./answerEngine');
const visionModel = require('./adapters/visionModel');
const textModel = require('./adapters/textModel');

const router = express.Router();

const aiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => (req.auth && req.auth.sub) || req.ip,
  message: { error: 'Too many AI requests. Please wait and try again.' },
});

router.post('/answer', aiLimiter, async (req, res) => {
  try {
    const body = req.body && typeof req.body === 'object' ? req.body : {};
    const result = await answerEngine.answer({
      query: body.query,
      category: body.category,
      history: body.history,
      location: body.location,
      language: body.language,
    });
    res.status(200).json(result);
  } catch (e) {
    res.status(500).json({
      ok: false, intent: 'general',
      answer: 'The Rural Intelligence service hit an internal error; no answer was composed and no tools are claimed to have run.',
      sources: [], figures: [], calculations: [],
      warnings: ['Internal gateway error: retry or contact support.'],
      confidence: 'low', dataPeriod: null, series: null, toolsRun: [],
      capability: { textModel: textModel.configured(), visionModel: visionModel.configured() },
      disclaimer: 'AI-generated content can be wrong.',
      error: String((e && e.message) || e),
    });
  }
});

router.post('/image', aiLimiter, async (req, res) => {
  const body = req.body && typeof req.body === 'object' ? req.body : {};
  const problem = visionModel.validateInput({
    imageBase64: body.imageBase64,
    mimeType: body.mimeType,
  });
  if (problem) {
    return res.status(400).json({
      ok: false, status: 'invalid_image', observation: null, message: problem,
    });
  }
  const result = await visionModel.analyze({
    imageBase64: body.imageBase64,
    mimeType: String(body.mimeType || '').toLowerCase(),
    question: body.question,
  });
  res.status(200).json(result);
});

router.get('/capabilities', (req, res) => {
  res.json({
    ok: true,
    text: textModel.capabilities(),
    vision: visionModel.configured()
      ? { visionModel: true, reason: 'configured via VISION_BASE_URL' }
      : { visionModel: false, reason: 'VISION_BASE_URL/VISION_MODEL not set' },
    retrieval: {
      schemes: true, weatherHistory: true, weatherForecast: true, prices: false,
    },
    limits: {
      imageMime: [...visionModel.MIME_OK],
      imagePayloadChars: visionModel.MAX_B64_CHARS,
      mediaRetention: 'in-memory for the request only; never stored',
    },
  });
});

module.exports = router;
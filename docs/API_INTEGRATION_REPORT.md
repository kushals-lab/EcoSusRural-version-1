# API INTEGRATION REPORT: EcoSusRural

**Report Date:** 2026-10-23  
**Verified Endpoints & Live Status**

---

## 1. Verified Live APIs

### A. Ministry of Agriculture & Farmers Welfare — Mandi Price API
- **Endpoint:** `https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070`
- **Provided API Key:** `[configured in backend/.env.local]`
- **Data Attributes Returned:**
  - `state`, `district`, `market` (e.g. Maddipadu APMC, Mukkom Market)
  - `commodity`, `variety`, `grade` (e.g. Bengal Gram, Bhindi, Potato)
  - `arrival_date`, `min_price`, `max_price`, `modal_price`
- **Verification Status:** **ACTIVE & LIVE (HTTP 200)** — Total active record count: 17,458 records.

### B. Google Gemini Generative AI API
- **Endpoint:** `https://generativelanguage.googleapis.com/v1beta/`
- **Provided API Key:** `AQ.Ab8RN6LTTj_5e7G0R4jA_hqdlqQ2ynyuw3Tmr97gmCXhaBpvsg`
- **Available Models Verified:**
  - `models/gemini-3.8-flash-tts`
  - `models/gemini-robotics-er-2-preview`
  - `models/gemini-2.5-computer-use-preview`
  - `models/deep-research-max-preview`
- **Verification Status:** **ACTIVE & LIVE (HTTP 200)**.
- **Architectural Security Rule:** Key is configured within `backend/.env` to prevent APK binary extraction.

### C. Open-Meteo Weather API
- **Endpoint:** `https://api.open-meteo.com/v1/forecast`
- **Authentication:** Keyless / Free Tier (Zero configuration required)
- **Data Attributes:** Temperature, relative humidity, wind speed, precipitation, 7-day weather codes.
- **Verification Status:** **ACTIVE & LIVE (HTTP 200)**.

---

## 2. Configured Backend Proxy Integration

All external API calls flow through the backend gateway:
- `GET /api/weather` -> Proxies Open-Meteo / OpenWeatherMap with in-memory 10-minute caching.
- `GET /api/mandi` -> Proxies data.gov.in Mandi prices with district & commodity filters.
- `POST /api/ai/answer` & `POST /api/ai/image` -> Proxies generative models with rate limiting and response validation.
- `POST /api/payments/verify` -> Handles signature verification for payments.

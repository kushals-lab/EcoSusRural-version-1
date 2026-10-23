# Runtime configuration contract

The Express backend, Flutter/Dart client, and Python AI service should receive environment-backed configuration rather than embedding URLs, ports, and tokens directly in source.

## Backend

Required environment variables:

- API_BASE_URL — Flutter/Dart API base URL for the mobile/web client. Default: http://127.0.0.1:5000/api
- AI_SERVICE_URL — AI service base endpoint. Default: http://127.0.0.1:8000
- AI_SERVICE_COMPUTE_PATH — AI compute route. Default: /compute
- AI_SERVICE_TOKEN — optional bearer token for the AI service. Leave empty if the AI service does not require auth
- AUTH_TOKEN — token returned by the auth/login route. Default: jwt_mock_token_key
- WEATHER_API_BASE_URL — Open-Meteo endpoint. Default: https://api.open-meteo.com/v1/forecast
- DEFAULT_LATITUDE / DEFAULT_LONGITUDE — fallback weather query location. Defaults: 21.5999 / 71.2162
- CORS_ORIGIN — allowed CORS origin or *

The backend sample file is available in `backend/.env.example`.

## Flutter/Dart client

Required environment variables:

- API_BASE_URL — backend base endpoint used by ApiClient and AppConfig
- AI_SERVICE_URL — service endpoint used by the AI service gate
- WEATHER_API_BASE_URL — weather service base endpoint

The client reads these via `String.fromEnvironment` and falls back to localhost examples when no environment variable has been injected by the build or wrapper.

## Python AI service

Required environment variables:

- AI_HOST — host interface for the FastAPI server, default 127.0.0.1
- AI_PORT — port for the FastAPI service, default 8000
- AI_SERVICE_SECRET / AI_SERVICE_TOKEN — runtime secret or bearer token expectation when invoking the service from the backend or other components

The AI service sample file is available in `ai_service/.env.example`.

const basePort = Number.parseInt(process.env.BACKEND_PORT || process.env.PORT || '5000', 10);

const config = {
  port: Number.isFinite(basePort) ? basePort : 5000,
  frontendApiBaseUrl: process.env.API_BASE_URL || 'http://127.0.0.1:5000/api',
  aiServiceUrl: (process.env.AI_SERVICE_URL || 'http://127.0.0.1:8000').replace(/\/$/, ''),
  aiServiceComputePath: process.env.AI_SERVICE_COMPUTE_PATH || '/compute',
  aiServiceToken: process.env.AI_SERVICE_TOKEN || process.env.AI_API_KEY || '',
  authToken: process.env.AUTH_TOKEN || process.env.JWT_MOCK_TOKEN_KEY || 'jwt_mock_token_key',
  weatherApiBaseUrl: process.env.WEATHER_API_BASE_URL || 'https://api.open-meteo.com/v1/forecast',
  weatherApiKey: process.env.WEATHER_API_KEY || '',
  weatherApiHeader: process.env.WEATHER_API_HEADER || '',
  defaultLatitude: process.env.DEFAULT_LATITUDE || '21.5999',
  defaultLongitude: process.env.DEFAULT_LONGITUDE || '71.2162',
  corsOrigin: process.env.CORS_ORIGIN || '*',
};

module.exports = config;

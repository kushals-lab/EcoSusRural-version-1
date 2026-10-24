const basePort = Number.parseInt(process.env.BACKEND_PORT || process.env.PORT || '5000', 10);
const isProduction = process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'prod';

const config = {
  port: Number.isFinite(basePort) ? basePort : 5000,
  // Loopback by default prevents accidental LAN/public exposure during local work.
  host: process.env.BACKEND_HOST || '127.0.0.1',
  frontendApiBaseUrl: process.env.API_BASE_URL || 'http://127.0.0.1:5000/api',
  aiServiceUrl: (process.env.AI_SERVICE_URL || 'http://127.0.0.1:8000').replace(/\/$/, ''),
  aiServiceComputePath: process.env.AI_SERVICE_COMPUTE_PATH || '/compute',
  aiServiceToken: process.env.AI_SERVICE_TOKEN || process.env.AI_API_KEY || '',
  weatherApiBaseUrl: process.env.WEATHER_API_BASE_URL || 'https://api.open-meteo.com/v1/forecast',
  weatherApiKey: process.env.WEATHER_API_KEY || '',
  weatherApiHeader: process.env.WEATHER_API_HEADER || '',
  defaultLatitude: process.env.DEFAULT_LATITUDE || '21.5999',
  defaultLongitude: process.env.DEFAULT_LONGITUDE || '71.2162',
  corsOrigin: process.env.CORS_ORIGIN || '*',
};

function assertProductionConfig() {
  if (!isProduction) return;
  const failures = [];
  if (!process.env.JWT_SECRET || process.env.JWT_SECRET.trim().length < 32) {
    failures.push('JWT_SECRET (minimum 32 characters)');
  }
  if (!process.env.MONGODB_URI || !process.env.MONGODB_URI.startsWith('mongodb')) {
    failures.push('a valid MONGODB_URI');
  }
  if (!config.corsOrigin || config.corsOrigin === '*') {
    failures.push('a specific CORS_ORIGIN');
  }
  if (failures.length) {
    throw new Error(`[config] Refusing production startup without ${failures.join(', ')}`);
  }
}

module.exports = { ...config, isProduction, assertProductionConfig };

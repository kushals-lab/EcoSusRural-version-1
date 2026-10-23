class AppConfig {
  static const String appName = 'EcoSusRural';
  static const String paymentProviderName = 'EcoBharatPay';

  // Runtime contract for the Flutter/Dart client. Values should be supplied
  // by dart-define or a generated launch wrapper and default to the
  // local development hosts documented for the repository.
  static String get apiBaseUrl =>
      const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:5000/api');

  static String get aiServiceUrl =>
      const String.fromEnvironment('AI_SERVICE_URL', defaultValue: 'http://127.0.0.1:8000');

  /// Rural Intelligence AI gateway (self-hosted Express backend).
  ///
  /// SECURITY: No model-provider key is ever bundled into the client and no
  /// third-party generative endpoint is called from this app. All AI
  /// inference runs server-side behind /api/ai/*, which this URL only names.
  /// Configure at build time with --dart-define=AI_GATEWAY_URL=...; when the
  /// gateway is unreachable, the assistant uses its offline advisory.
  static String get aiGatewayUrl =>
      const String.fromEnvironment('AI_GATEWAY_URL', defaultValue: 'http://127.0.0.1:5000/api');

  static String get weatherApiBaseUrl =>
      const String.fromEnvironment('WEATHER_API_BASE_URL', defaultValue: 'https://api.open-meteo.com/v1/forecast');

  /// Weather API key for providers that require authentication.
  ///
  /// SECURITY: Never bundle a provider key into a shipped client — it is
  /// extractable from the APK. Prefer the backend proxy (/api/weather).
  /// For local development only, pass the key with
  /// --dart-define=WEATHER_API_KEY=... When empty (the default), the Weather
  /// Intelligence screen uses keyless Open-Meteo.
  static String get weatherApiKey =>
      const String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');

  /// OpenWeatherMap 5-day/3-hour forecast endpoint used when
  /// [weatherApiKey] is configured.
  static const String openWeatherMapForecastUrl =
      'https://api.openweathermap.org/data/2.5/forecast';

  /// Custom HTTP header for weather API auth, e.g. 'Authorization: Bearer xxx'.
  /// Leave empty for query-param key auth (the default for most providers).
  static String get weatherApiHeader =>
      const String.fromEnvironment('WEATHER_API_HEADER', defaultValue: '');

  static const int connectTimeout = 5000; // ms
  static const int receiveTimeout = 5000; // ms
}
/// Comprehensive API registry for EcoSusRural.
library api_registry;

class ApiEntry {
  final String name;
  final String provider;
  final String baseUrl;
  final String purpose;
  final String authMethod;
  final bool isRequired;

  const ApiEntry({
    required this.name,
    required this.provider,
    required this.baseUrl,
    required this.purpose,
    required this.authMethod,
    this.isRequired = true,
  });
}

class ApiRegistry {
  static const all = <ApiEntry>[
    ApiEntry(name: 'Open-Meteo Weather', provider: 'Open-Meteo (free)', baseUrl: 'https://api.open-meteo.com/v1/forecast', purpose: 'Weather, crop advisory, village forecast', authMethod: 'None'),
    ApiEntry(name: 'Google Maps / Mapbox', provider: 'Google Cloud / Mapbox', baseUrl: 'https://maps.googleapis.com/maps/api', purpose: 'Maps, geocoding, places, ETA estimation', authMethod: 'API_KEY'),
    ApiEntry(name: 'Firebase Auth', provider: 'Firebase (Google)', baseUrl: 'https://identitytoolkit.googleapis.com', purpose: 'Phone OTP login, user authentication', authMethod: 'Firebase SDK'),
    ApiEntry(name: 'Firebase Cloud Firestore', provider: 'Firebase (Google)', baseUrl: 'https://firestore.googleapis.com', purpose: 'Real-time data sync for chat, orders', authMethod: 'Firebase SDK'),
    ApiEntry(name: 'Firebase Cloud Messaging', provider: 'Firebase (Google)', baseUrl: 'https://fcm.googleapis.com', purpose: 'Push notifications for rides, payments', authMethod: 'Firebase SDK'),
    ApiEntry(name: 'Firebase Cloud Storage', provider: 'Firebase (Google)', baseUrl: 'https://firebasestorage.googleapis.com', purpose: 'Image/video/media uploads', authMethod: 'Firebase SDK'),
    ApiEntry(name: 'UPI / Razorpay / Cashfree', provider: 'Razorpay / Cashfree', baseUrl: 'https://api.razorpay.com/v1', purpose: 'Payments, QR scan, wallet, transfers', authMethod: 'API_KEY + Secret'),
    ApiEntry(name: 'Rapido / Ola / Uber Partner', provider: 'Ride-hailing partners', baseUrl: 'Partner endpoints', purpose: 'Cab/bike booking, live driver tracking', authMethod: 'OAuth / API_KEY'),
    ApiEntry(name: 'ConfirmTKT / IRCTC', provider: 'ConfirmTKT / IRCTC', baseUrl: 'https://api.confirmtkt.com', purpose: 'Train booking, PNR status', authMethod: 'API_KEY'),
    ApiEntry(name: 'BookMyShow', provider: 'BookMyShow', baseUrl: 'https://api.bookmyshow.com', purpose: 'Movies, events, shows booking', authMethod: 'API_KEY'),
    ApiEntry(name: 'YouTube Data API', provider: 'Google', baseUrl: 'https://www.googleapis.com/youtube/v3', purpose: 'Long-form video hosting, streaming', authMethod: 'API_KEY'),
    ApiEntry(name: 'Twilio / MSG91', provider: 'Twilio / MSG91', baseUrl: 'https://api.twilio.com', purpose: 'SMS OTP, transaction alerts', authMethod: 'API_KEY + SID'),
    ApiEntry(name: 'Rural Intelligence Gateway', provider: 'Self-hosted Express backend (OpenAI-compatible adapters)', baseUrl: 'http://127.0.0.1:5000/api/ai', purpose: 'Rural search, evidence answers, vision pipeline', authMethod: 'NONE (rate-limited)'),
    ApiEntry(name: 'OpenStreetMap / Nominatim', provider: 'OpenStreetMap', baseUrl: 'https://nominatim.openstreetmap.org', purpose: 'Offline maps, geocoding', authMethod: 'None'),
    ApiEntry(name: 'Government Schemes', provider: 'data.gov.in', baseUrl: 'https://api.data.gov.in', purpose: 'MSP, schemes, farmer data', authMethod: 'API_KEY (free)', isRequired: false),
    ApiEntry(name: 'Telegram Bot', provider: 'Telegram', baseUrl: 'https://api.telegram.org', purpose: 'Chat bot, order updates', authMethod: 'BOT_TOKEN', isRequired: false),
  ];

  static List<ApiEntry> get required => all.where((a) => a.isRequired).toList();
  static List<ApiEntry> get optional => all.where((a) => !a.isRequired).toList();
}
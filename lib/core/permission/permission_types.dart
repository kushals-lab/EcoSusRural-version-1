/// Permission types required across EcoSusRural features.
library permission_types;

/// All platform permission types the app may request.
enum AppPermission {
  location,
  camera,
  microphone,
  notifications,
  phone,
  storage,
  contacts,
  bluetooth,
  sensors,
  advertisingId,
  backgroundLocation,
  nearbyDevices,
  pictureInPicture,
}

/// Feature-level permission requirement declaration.
class FeaturePermission {
  final String featureTitle;
  final String whyNeeded;
  final List<AppPermission> requiredPermissions;
  final List<AppPermission> optionalPermissions;
  final bool locationIsEssential;

  const FeaturePermission({
    required this.featureTitle,
    required this.whyNeeded,
    required this.requiredPermissions,
    this.optionalPermissions = const [],
    this.locationIsEssential = false,
  });
}

/// Permission request outcomes. Mirrors the semantics of the statuses used
/// previously, so callers keep working unchanged. The app currently has no
/// native hardware consumers (no camera/microphone/GPS plugin is bundled),
/// so the manager reports [granted] unless a real consumer is added.
enum PermissionStatus {
  granted,
  denied,
  restricted,
  limited,
  permanentlyDenied;

  bool get isGranted => this == PermissionStatus.granted;
  bool get isLimited => this == PermissionStatus.limited;
}

/// Pre-declared permission requirements for every major feature.
class FeaturePermissionRegistry {
  static const rideBooking = FeaturePermission(
    featureTitle: 'Rides (bike/auto/cab)',
    whyNeeded: 'We need your location to match you with the nearest partner and show ETA.',
    requiredPermissions: [AppPermission.location, AppPermission.phone],
    optionalPermissions: [AppPermission.notifications, AppPermission.backgroundLocation, AppPermission.bluetooth],
    locationIsEssential: true,
  );

  static const rideBookingForOthers = FeaturePermission(
    featureTitle: 'Book a ride for someone else',
    whyNeeded: 'A live map is shown so you can drop a pin for the passenger pickup. Location is required for the map to work.',
    requiredPermissions: [AppPermission.location, AppPermission.camera, AppPermission.phone],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: true,
  );

  static const messaging = FeaturePermission(
    featureTitle: 'Messages & voice notes',
    whyNeeded: 'Camera and microphone let you send photos/voice notes. Storage saves media you receive.',
    requiredPermissions: [AppPermission.camera, AppPermission.microphone],
    optionalPermissions: [AppPermission.storage, AppPermission.notifications],
    locationIsEssential: false,
  );

  static const payments = FeaturePermission(
    featureTitle: 'EcoBharatPay (QR / UPI)',
    whyNeeded: 'Camera scans QR / payment codes. Phone state helps OTP and device binding.',
    requiredPermissions: [AppPermission.camera, AppPermission.phone],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: false,
  );

  static const videoReels = FeaturePermission(
    featureTitle: 'Reels / Shorts creation',
    whyNeeded: 'Camera, microphone, and storage are needed to record and save your clips.',
    requiredPermissions: [AppPermission.camera, AppPermission.microphone, AppPermission.storage],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: false,
  );

  static const longVideo = FeaturePermission(
    featureTitle: 'Long video player',
    whyNeeded: 'Storage is needed to download videos offline.',
    requiredPermissions: [AppPermission.storage],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: false,
  );

  static const health = FeaturePermission(
    featureTitle: 'Health & telemedicine',
    whyNeeded: 'Camera scans prescriptions and reports. Notifications remind you of appointments.',
    requiredPermissions: [AppPermission.camera],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: false,
  );

  static const marketplace = FeaturePermission(
    featureTitle: 'Marketplace (products / orders)',
    whyNeeded: 'Location helps show nearby mandis and delivery estimates. Notifications track orders.',
    requiredPermissions: [AppPermission.location],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: false,
  );

  static const weather = FeaturePermission(
    featureTitle: 'Weather & farm advisory',
    whyNeeded: 'Location is needed to show village-level weather and crop advice.',
    requiredPermissions: [AppPermission.location],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: true,
  );

  static const seller = FeaturePermission(
    featureTitle: 'Seller dashboard',
    whyNeeded: 'Location confirms your operational area. Camera uploads product photos.',
    requiredPermissions: [AppPermission.location, AppPermission.camera],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: false,
  );

  static const smartDryer = FeaturePermission(
    featureTitle: 'Smart Solar Dryer (device link)',
    whyNeeded: 'Nearby-devices/Bluetooth finds the ESP32 dryer; location is only needed on Android for BLE scans. Notifications flag safety and completion alerts.',
    requiredPermissions: [AppPermission.bluetooth, AppPermission.nearbyDevices],
    optionalPermissions: [AppPermission.notifications, AppPermission.location],
    locationIsEssential: false,
  );

  static const settings = FeaturePermission(
    featureTitle: 'Settings & account',
    whyNeeded: 'Notifications keep you informed. Phone state helps with account verification.',
    requiredPermissions: [AppPermission.phone],
    optionalPermissions: [AppPermission.notifications],
    locationIsEssential: false,
  );

  static FeaturePermission? forFeature(String feature) {
    final map = {
      'ride': rideBooking,
      'ride_for_other': rideBookingForOthers,
      'messages': messaging,
      'payments': payments,
      'reels': videoReels,
      'long_video': longVideo,
      'health': health,
      'marketplace': marketplace,
      'weather': weather,
      'seller': seller,
      'settings': settings,
      'smart_dryer': smartDryer,
    };
    return map[feature];
  }
}
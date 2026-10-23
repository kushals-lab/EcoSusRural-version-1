import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class DrmService {
  static const MethodChannel _channel = MethodChannel('com.ecosusrural.security/drm');

  /// Locks the screen from being captured, recorded, or screenshot.
  static Future<void> secureScreen() async {
    if (kIsWeb) return; // Web requires different handling (CSS/JS hooks)

    try {
      await _channel.invokeMethod('secureScreen');
      debugPrint('Security: Screen capture protection ENABLED.');
    } on MissingPluginException {
      debugPrint('Security: Native DRM channel unavailable on this target; app fallback mode enabled.');
    } on PlatformException catch (e) {
      debugPrint("Security Error: Failed to secure screen: '${e.message}'.");
    } catch (e) {
      debugPrint('Security Error: Failed to secure screen: $e');
    }
  }

  /// Unlocks the screen (useful if you want to allow screenshots on a specific shareable receipt page).
  static Future<void> unsecureScreen() async {
    if (kIsWeb) return;

    try {
      await _channel.invokeMethod('unsecureScreen');
      debugPrint('Security: Screen capture protection DISABLED.');
    } on MissingPluginException {
      debugPrint('Security: Native DRM channel unavailable on this target; app fallback mode enabled.');
    } on PlatformException catch (e) {
      debugPrint("Security Error: Failed to unsecure screen: '${e.message}'.");
    } catch (e) {
      debugPrint('Security Error: Failed to unsecure screen: $e');
    }
  }
}
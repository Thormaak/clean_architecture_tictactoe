import 'package:flutter/services.dart';

import 'device_type.dart';

/// Contrôle les orientations autorisées selon le type d'appareil.
///
/// - Phone: Portrait uniquement
/// - Tablet: Toutes les orientations
class OrientationController {
  /// Initialise les orientations autorisées selon le type d'appareil.
  ///
  /// Doit être appelé après [WidgetsFlutterBinding.ensureInitialized()]
  /// et avant [runApp()].
  static Future<void> initialize() async {
    final deviceType = DeviceTypeDetector.detect();

    if (deviceType == DeviceType.tablet) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }
}

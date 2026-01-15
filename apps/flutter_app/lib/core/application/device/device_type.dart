import 'dart:ui';

import '../../presentation/theme/layout_tokens.dart';

/// Types d'appareils supportés.
enum DeviceType { phone, tablet }

/// Détecte le type d'appareil basé sur la taille physique de l'écran.
class DeviceTypeDetector {
  /// Détecte si l'appareil est un phone ou une tablet.
  ///
  /// Utilise le shortestSide (la plus petite dimension) pour déterminer
  /// le type d'appareil, car c'est plus fiable que la largeur seule
  /// qui change selon l'orientation.
  static DeviceType detect() {
    final view = PlatformDispatcher.instance.views.first;
    final physicalWidth = view.physicalSize.width;
    final physicalHeight = view.physicalSize.height;
    final devicePixelRatio = view.devicePixelRatio;

    // Utiliser la plus petite dimension (shortestSide)
    final shortestSide =
        (physicalWidth < physicalHeight ? physicalWidth : physicalHeight) /
        devicePixelRatio;

    return shortestSide >= LayoutTokens.tabletBreakpoint
        ? DeviceType.tablet
        : DeviceType.phone;
  }
}

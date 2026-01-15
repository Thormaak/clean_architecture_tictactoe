import 'package:flutter/material.dart';

import '../theme/layout_tokens.dart';

/// Extension sur [BuildContext] pour accéder facilement aux informations
/// de taille d'écran et de type d'appareil.
extension BuildContextScreenExtension on BuildContext {
  /// Retourne la taille de l'écran.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Retourne la largeur de l'écran.
  double get screenWidth => screenSize.width;

  /// Retourne la hauteur de l'écran.
  double get screenHeight => screenSize.height;

  /// Retourne la plus petite dimension de l'écran (shortestSide).
  double get shortestSide => screenSize.shortestSide;

  /// Retourne l'orientation actuelle de l'écran.
  Orientation get orientation => MediaQuery.orientationOf(this);

  /// Retourne `true` si l'écran est en mode paysage.
  bool get isLandscape => orientation == Orientation.landscape;

  /// Retourne `true` si l'écran est en mode portrait.
  bool get isPortrait => orientation == Orientation.portrait;

  /// Retourne `true` si l'appareil est une tablette.
  ///
  /// Basé sur le [shortestSide] >= [LayoutTokens.tabletBreakpoint] (600dp).
  bool get isTablet => shortestSide >= LayoutTokens.tabletBreakpoint;

  /// Retourne `true` si l'appareil est un téléphone.
  bool get isPhone => !isTablet;

  /// Retourne `true` si l'écran est considéré comme large.
  ///
  /// Basé sur la [screenWidth] >= [LayoutTokens.largeScreenBreakpoint] (900dp).
  bool get isLargeScreen => screenWidth >= LayoutTokens.largeScreenBreakpoint;
}

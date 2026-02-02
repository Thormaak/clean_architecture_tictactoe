import 'package:flutter/material.dart';

/// Layout tokens for spacing, radius, durations and breakpoints.
class LayoutTokens {
  LayoutTokens._();

  // Breakpoints (en dp)
  /// Seuil pour différencier phone/tablet (shortestSide).
  /// Standard Material Design.
  static const double tabletBreakpoint = 600;

  /// Seuil pour considérer un grand écran tablet/desktop (width).
  static const double largeScreenBreakpoint = 900;

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  /// Spacing between buttons in overlays (12px)
  static const double spacingButton = 12;

  static const EdgeInsets pagePaddingHorizontal = EdgeInsets.symmetric(
    horizontal: spacingLg,
  );
  static const EdgeInsets headerPadding = EdgeInsets.all(spacingMd);
  static const EdgeInsets cardHorizontalPadding = EdgeInsets.symmetric(
    horizontal: spacingLg,
  );

  // Radius
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;

  // Durations
  static const Duration durationFast = Duration(milliseconds: 100);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationMedium = Duration(milliseconds: 400);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationSlower = Duration(milliseconds: 600);

  // Content max widths
  static const double menuCardsMaxWidth = 520;
  static const double pageContentMaxWidthLarge = 1000;
  static const double pageContentMaxWidthMobile = 600;
}

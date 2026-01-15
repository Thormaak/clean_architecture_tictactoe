import 'package:flutter/material.dart';

/// Gaming-style theme with dark background and neon accents
class GamingTheme {
  GamingTheme._();

  // Neon/Gaming colors
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentCyan = Color(0xFF06B6D4);
  static const accentPink = Color(0xFFEC4899);
  static const accentPurple = Color(0xFF8B5CF6);
  static const darkBackground = Color(0xFF0F0F23);
  static const cardBackground = Color(0xFF1A1A2E);

  // Common background gradient
  static const pageBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, Color(0xFF1A1A3E)],
  );

  // Game-specific colors
  static const xMarkColor = accentCyan;
  static const oMarkColor = accentPink;
  static const gridLineColor = Color(0x80A855F7); // Purple 50%
  static const goldColor = Color(0xFFFFD700);

  // Game-specific gradients
  static const xPlayerGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const oPlayerGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const localModeGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const aiModeGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Difficulty gradients
  static const difficultyEasyGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const difficultyMediumGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const difficultyHardGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Best Of gradients
  static const bestOfBo1Gradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const bestOfBo3Gradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const bestOfBo5Gradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const boardGradientBorder = LinearGradient(
    colors: [accentCyan, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Box shadows for game elements
  static List<BoxShadow> glowShadow(
    Color color, {
    double blur = 15,
    double alpha = 0.5,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: blur,
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> get boardShadow => [
    BoxShadow(
      color: accentPurple.withValues(alpha: 0.25),
      blurRadius: 30,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: accentCyan.withValues(alpha: 0.1),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  // Animation durations
  static const markAnimationDuration = Duration(milliseconds: 300);
  static const turnTransitionDuration = Duration(milliseconds: 200);
  static const winningLineAnimationDuration = Duration(milliseconds: 400);
  static const celebrationDuration = Duration(seconds: 3);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ).copyWith(surface: darkBackground),
    scaffoldBackgroundColor: darkBackground,
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

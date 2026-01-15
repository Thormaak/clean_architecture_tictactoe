import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/gaming_theme.dart';

/// "Sudden Death" label for single games
class SuddenDeathLabel extends StatelessWidget {
  final String label;

  const SuddenDeathLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GamingTheme.accentPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GamingTheme.accentPurple.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: GamingTheme.accentPurple,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

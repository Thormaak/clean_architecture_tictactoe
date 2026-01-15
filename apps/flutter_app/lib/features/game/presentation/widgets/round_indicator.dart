import 'package:flutter/material.dart';

import '../../../../core/presentation/l10n/app_localizations.dart';

/// Widget to display current round number during gameplay
class RoundIndicator extends StatelessWidget {
  final int currentRound;
  final int maxRounds;

  const RoundIndicator({
    super.key,
    required this.currentRound,
    required this.maxRounds,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        l10n.roundOf(currentRound, maxRounds),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

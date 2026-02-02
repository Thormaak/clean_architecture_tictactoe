import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../core/presentation/theme/gaming_theme.dart';
import '../../../../core/presentation/theme/layout_tokens.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import 'package:tictactoe/features/rules/rules.dart';

/// Pure presentation view for AI difficulty selection.
class DifficultyView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final ValueChanged<AIDifficulty> onSelect;

  const DifficultyView({
    super.key,
    required this.onBack,
    required this.onSettings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GamingScaffold(
      child: SafeArea(
        child: Column(
          children: [
            GamingHeaderRow(
              title: l10n.chooseDifficulty,
              onBack: onBack,
              onSettings: onSettings,
            ),
            const SizedBox(height: LayoutTokens.spacingXl),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: LayoutTokens.menuCardsMaxWidth,
                ),
                child: _DifficultyCards(l10n: l10n, onSelect: onSelect),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCards extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueChanged<AIDifficulty> onSelect;

  const _DifficultyCards({required this.l10n, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final configs = [
      _DifficultyCardConfig(
        title: l10n.difficultyEasy,
        subtitle: l10n.difficultyEasySubtitle,
        icon: Icons.sentiment_satisfied_alt,
        gradient: GamingTheme.difficultyEasyGradient,
        onTap: () => onSelect(AIDifficulty.easy),
        delay: LayoutTokens.durationFast,
      ),
      _DifficultyCardConfig(
        title: l10n.difficultyMedium,
        subtitle: l10n.difficultyMediumSubtitle,
        icon: Icons.psychology,
        gradient: GamingTheme.difficultyMediumGradient,
        onTap: () => onSelect(AIDifficulty.medium),
        delay: LayoutTokens.durationFast + const Duration(milliseconds: 100),
      ),
      _DifficultyCardConfig(
        title: l10n.difficultyHard,
        subtitle: l10n.difficultyHardSubtitle,
        icon: Icons.whatshot,
        gradient: GamingTheme.difficultyHardGradient,
        onTap: () => onSelect(AIDifficulty.hard),
        delay: LayoutTokens.durationNormal,
      ),
    ];

    final cards = <Widget>[];
    for (var i = 0; i < configs.length; i++) {
      if (i > 0) {
        cards.add(const SizedBox(height: LayoutTokens.spacingMd));
      }
      final config = configs[i];
      cards.add(
        Padding(
              padding: LayoutTokens.cardHorizontalPadding,
              child: GamingGradientCard(
                title: config.title,
                subtitle: config.subtitle,
                icon: config.icon,
                gradient: config.gradient,
                onTap: config.onTap,
              ),
            )
            .animate(delay: config.delay)
            .fadeIn(duration: LayoutTokens.durationMedium)
            .slideX(begin: 0.2),
      );
    }

    return Column(children: cards);
  }
}

class _DifficultyCardConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final Duration delay;

  const _DifficultyCardConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.delay,
  });
}

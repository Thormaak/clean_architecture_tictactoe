import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tictactoe/features/rules/domain/value_objects/best_of.dart';

import '../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../core/presentation/theme/gaming_theme.dart';
import '../../../../core/presentation/theme/layout_tokens.dart';
import '../../../../core/presentation/widgets/widgets.dart';

/// Pure presentation view for Best Of selection.
class BestOfSelectionView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final ValueChanged<BestOf> onSelect;

  const BestOfSelectionView({
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
              title: l10n.chooseFormat,
              onBack: onBack,
              onSettings: onSettings,
            ),
            const SizedBox(height: LayoutTokens.spacingXl),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: _BestOfCards(l10n: l10n, onSelect: onSelect),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestOfCards extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueChanged<BestOf> onSelect;

  const _BestOfCards({required this.l10n, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final configs = [
      _BestOfCardConfig(
        title: l10n.bo1,
        subtitle: l10n.bo1Subtitle,
        icon: Icons.looks_one,
        gradient: GamingTheme.bestOfBo1Gradient,
        onTap: () => onSelect(BestOf.bo1),
        delay: LayoutTokens.durationFast,
      ),
      _BestOfCardConfig(
        title: l10n.bo3,
        subtitle: l10n.bo3Subtitle,
        icon: Icons.looks_3,
        gradient: GamingTheme.bestOfBo3Gradient,
        onTap: () => onSelect(BestOf.bo3),
        delay: LayoutTokens.durationFast + const Duration(milliseconds: 100),
      ),
      _BestOfCardConfig(
        title: l10n.bo5,
        subtitle: l10n.bo5Subtitle,
        icon: Icons.looks_5,
        gradient: GamingTheme.bestOfBo5Gradient,
        onTap: () => onSelect(BestOf.bo5),
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

class _BestOfCardConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final Duration delay;

  const _BestOfCardConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.delay,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/extensions/build_context_extensions.dart';
import '../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../core/presentation/theme/gaming_theme.dart';
import '../../../../core/presentation/theme/layout_tokens.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../widgets/animated_title.dart';
import '../widgets/decorative_mini_board.dart';

/// Main home view with game mode selection.
/// Pure presentation widget - receives callbacks for navigation.
class HomeView extends StatelessWidget {
  final VoidCallback onLocalGame;
  final VoidCallback onAIGame;
  final VoidCallback onSettings;

  const HomeView({
    super.key,
    required this.onLocalGame,
    required this.onAIGame,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLargeScreen = context.isLargeScreen;

    return GamingScaffold(
      child: SafeArea(
        child: Column(
          children: [
            GamingHeaderRow(onSettings: onSettings),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen
                        ? LayoutTokens.pageContentMaxWidthLarge
                        : LayoutTokens.pageContentMaxWidthMobile,
                  ),
                  child:
                      isLargeScreen
                          ? _TabletHomeContent(
                            l10n: l10n,
                            onLocalGame: onLocalGame,
                            onAIGame: onAIGame,
                          )
                          : _MobileHomeContent(
                            l10n: l10n,
                            onLocalGame: onLocalGame,
                            onAIGame: onAIGame,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileHomeContent extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onLocalGame;
  final VoidCallback onAIGame;

  const _MobileHomeContent({
    required this.l10n,
    required this.onLocalGame,
    required this.onAIGame,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated Title
        AnimatedTitle(title: l10n.appTitle)
            .animate()
            .fadeIn(duration: LayoutTokens.durationSlower)
            .slideY(begin: -0.3, end: 0),

        const SizedBox(height: LayoutTokens.spacingXl),

        // Decorative Mini Board
        const DecorativeMiniBoard(),

        const Spacer(flex: 1),

        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutTokens.menuCardsMaxWidth,
            ),
            child: _GameModeCards(
              l10n: l10n,
              onLocalGame: onLocalGame,
              onAIGame: onAIGame,
            ),
          ),
        ),

        const Spacer(flex: 1),
      ],
    );
  }
}

class _TabletHomeContent extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onLocalGame;
  final VoidCallback onAIGame;

  const _TabletHomeContent({
    required this.l10n,
    required this.onLocalGame,
    required this.onAIGame,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedTitle(title: l10n.appTitle)
                  .animate()
                  .fadeIn(duration: LayoutTokens.durationSlower)
                  .slideY(begin: -0.3, end: 0),
              const SizedBox(height: LayoutTokens.spacingXl),
              const DecorativeMiniBoard(),
            ],
          ),
        ),
        const SizedBox(width: LayoutTokens.spacingXl),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: LayoutTokens.menuCardsMaxWidth,
                  ),
                  child: _GameModeCards(
                    l10n: l10n,
                    onLocalGame: onLocalGame,
                    onAIGame: onAIGame,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameModeCards extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onLocalGame;
  final VoidCallback onAIGame;

  const _GameModeCards({
    required this.l10n,
    required this.onLocalGame,
    required this.onAIGame,
  });

  @override
  Widget build(BuildContext context) {
    final configs = [
      _GameModeCardConfig(
        icon: Icons.people,
        title: l10n.twoPlayers,
        subtitle: l10n.gameModeLocalSubtitle,
        gradient: GamingTheme.localModeGradient,
        onTap: onLocalGame,
        delay: LayoutTokens.durationMedium,
      ),
      _GameModeCardConfig(
        icon: Icons.smart_toy,
        title: l10n.playAgainstAI,
        subtitle: l10n.gameModeAISubtitle,
        gradient: GamingTheme.aiModeGradient,
        onTap: onAIGame,
        delay: LayoutTokens.durationSlow,
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
                icon: config.icon,
                title: config.title,
                subtitle: config.subtitle,
                gradient: config.gradient,
                onTap: config.onTap,
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
              )
              .animate()
              .fadeIn(delay: config.delay, duration: LayoutTokens.durationSlow)
              .slideX(begin: -0.2, end: 0),
        ),
      );
    }

    return Column(children: cards);
  }
}

class _GameModeCardConfig {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final Duration delay;

  const _GameModeCardConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    required this.delay,
  });
}

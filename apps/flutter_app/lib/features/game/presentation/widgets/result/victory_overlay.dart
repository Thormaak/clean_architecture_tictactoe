import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../../core/presentation/theme/gaming_theme.dart';
import '../../../../../core/presentation/theme/layout_tokens.dart';
import '../../../../../core/presentation/widgets/widgets.dart';
import 'package:tictactoe/features/rules/rules.dart';
import 'confetti_effect.dart';

/// Overlay displayed when a player wins
class VictoryOverlay extends StatelessWidget {
  final Player winner;
  final int moveCount;
  final VoidCallback? onRematch;
  final VoidCallback? onHome;

  const VictoryOverlay({
    super.key,
    required this.winner,
    required this.moveCount,
    this.onRematch,
    this.onHome,
  });

  Color get _winnerColor =>
      winner.mark == PlayerMark.x
          ? GamingTheme.xMarkColor
          : GamingTheme.oMarkColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        // Dark backdrop
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.black.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),

        // Confetti
        Positioned.fill(
          child: ConfettiEffect(primaryColor: _winnerColor, particleCount: 50),
        ),

        // Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon
              Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          GamingTheme.goldColor,
                          GamingTheme.goldColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: GamingTheme.glowShadow(
                        GamingTheme.goldColor,
                        blur: 30,
                        alpha: 0.6,
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 48,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .rotate(begin: -0.02, end: 0.02, duration: 1.seconds),

              const SizedBox(height: LayoutTokens.spacingLg),

              // Victory text
              ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [_winnerColor, Colors.white],
                        ).createShader(bounds),
                    child: Text(
                      l10n.victory.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Colors.white,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0)
                  .then()
                  .shimmer(duration: 2.seconds, color: Colors.white30),

              const SizedBox(height: LayoutTokens.spacingSm),

              // Winner name
              Text(
                winner.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _winnerColor,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

              const SizedBox(height: LayoutTokens.spacingSm),

              // Move count
              Text(
                l10n.wonInMoves(moveCount),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

              const SizedBox(height: LayoutTokens.spacingXl),

              // Action buttons
              Padding(
                    padding: LayoutTokens.cardHorizontalPadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onRematch != null) ...[
                          SizedBox(
                            width: 220,
                            child: GamingActionButton.filled(
                              label: l10n.rematch.toUpperCase(),
                              icon: Icons.replay,
                              gradient: const LinearGradient(
                                colors: [
                                  GamingTheme.accentPurple,
                                  GamingTheme.accentPink,
                                ],
                              ),
                              onTap: onRematch!,
                            ),
                          ),
                        ],
                        if (onHome != null) ...[
                          if (onRematch != null) const SizedBox(height: LayoutTokens.spacingButton),
                          SizedBox(
                            width: 220,
                            child: GamingActionButton.filled(
                              label: l10n.menu.toUpperCase(),
                              icon: Icons.home,
                              gradient: const LinearGradient(
                                colors: [
                                  GamingTheme.accentPurple,
                                  GamingTheme.accentPink,
                                ],
                              ),
                              onTap: onHome!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 300.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}

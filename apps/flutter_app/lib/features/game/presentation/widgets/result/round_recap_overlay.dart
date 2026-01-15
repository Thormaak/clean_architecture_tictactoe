import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../../core/presentation/theme/gaming_theme.dart';
import '../../../../../core/presentation/theme/layout_tokens.dart';
import '../../../../../core/presentation/widgets/widgets.dart';
import 'package:tictactoe/features/rules/rules.dart';
import 'confetti_effect.dart';

/// Overlay displayed between rounds in a Best Of match
class RoundRecapOverlay extends StatelessWidget {
  final GameResult roundResult;
  final Player playerX;
  final Player playerO;
  final int playerXScore;
  final int playerOScore;
  final int currentRound;
  final int maxRounds;
  final VoidCallback onContinue;

  const RoundRecapOverlay({
    super.key,
    required this.roundResult,
    required this.playerX,
    required this.playerO,
    required this.playerXScore,
    required this.playerOScore,
    required this.currentRound,
    required this.maxRounds,
    required this.onContinue,
  });

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
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),

        // Confetti for winner
        if (roundResult is GameResultWin)
          Positioned.fill(
            child: ConfettiEffect(
              primaryColor:
                  (roundResult as GameResultWin).winner == PlayerMark.x
                      ? GamingTheme.xMarkColor
                      : GamingTheme.oMarkColor,
              particleCount: 30,
            ),
          ),

        // Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Round indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  l10n.roundOf(currentRound, maxRounds),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3, end: 0),

              const SizedBox(height: 24),

              // Result icon and text
              _RoundResultSection(
                l10n: l10n,
                roundResult: roundResult,
                playerX: playerX,
                playerO: playerO,
              ),

              const SizedBox(height: 32),

              // Score display
              _RoundScoreSection(
                l10n: l10n,
                playerX: playerX,
                playerO: playerO,
                playerXScore: playerXScore,
                playerOScore: playerOScore,
              ),

              const SizedBox(height: 32),

              // Continue button
              Padding(
                padding: LayoutTokens.cardHorizontalPadding,
                child: SizedBox(
                  width: 220,
                  child: GamingActionButton.filled(
                        label: l10n.nextRound.toUpperCase(),
                        gradient: const LinearGradient(
                          colors: [
                            GamingTheme.accentPurple,
                            GamingTheme.accentPink,
                          ],
                        ),
                        onTap: onContinue,
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 300.ms)
                      .slideY(begin: 0.3, end: 0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundResultSection extends StatelessWidget {
  final AppLocalizations l10n;
  final GameResult roundResult;
  final Player playerX;
  final Player playerO;

  const _RoundResultSection({
    required this.l10n,
    required this.roundResult,
    required this.playerX,
    required this.playerO,
  });

  @override
  Widget build(BuildContext context) {
    return roundResult.when(
      ongoing: () => const SizedBox.shrink(),
      win: (winner, _) {
        final isX = winner == PlayerMark.x;
        final winnerPlayer = isX ? playerX : playerO;
        final winnerColor =
            isX ? GamingTheme.xMarkColor : GamingTheme.oMarkColor;

        return Column(
          children: [
            // Trophy icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [winnerColor, winnerColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: GamingTheme.glowShadow(
                  winnerColor,
                  blur: 25,
                  alpha: 0.5,
                ),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 36,
              ),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),

            const SizedBox(height: 16),

            // Round winner text
            ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [winnerColor, Colors.white],
                      ).createShader(bounds),
                  child: Text(
                    l10n.roundWinner(winnerPlayer.name),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        );
      },
      draw: () {
        return Column(
          children: [
            // Handshake icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [GamingTheme.accentPurple, GamingTheme.accentPink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: GamingTheme.glowShadow(
                  GamingTheme.accentPurple,
                  blur: 25,
                  alpha: 0.5,
                ),
              ),
              child: const Icon(Icons.handshake, color: Colors.white, size: 36),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),

            const SizedBox(height: 16),

            // Draw text
            ShaderMask(
                  shaderCallback:
                      (bounds) => const LinearGradient(
                        colors: [
                          GamingTheme.accentPurple,
                          GamingTheme.accentPink,
                        ],
                      ).createShader(bounds),
                  child: Text(
                    l10n.roundDraw,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        );
      },
    );
  }
}

class _RoundScoreSection extends StatelessWidget {
  final AppLocalizations l10n;
  final Player playerX;
  final Player playerO;
  final int playerXScore;
  final int playerOScore;

  const _RoundScoreSection({
    required this.l10n,
    required this.playerX,
    required this.playerO,
    required this.playerXScore,
    required this.playerOScore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          l10n.score.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

        const SizedBox(height: 12),

        // Score cards
        Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoundScoreCard(
                  name: playerX.name,
                  score: playerXScore,
                  color: GamingTheme.xMarkColor,
                  isLeading: playerXScore > playerOScore,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                _RoundScoreCard(
                  name: playerO.name,
                  score: playerOScore,
                  color: GamingTheme.oMarkColor,
                  isLeading: playerOScore > playerXScore,
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
      ],
    );
  }
}

class _RoundScoreCard extends StatelessWidget {
  final String name;
  final int score;
  final Color color;
  final bool isLeading;

  const _RoundScoreCard({
    required this.name,
    required this.score,
    required this.color,
    required this.isLeading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isLeading ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isLeading ? 0.5 : 0.2),
          width: isLeading ? 2 : 1,
        ),
        boxShadow:
            isLeading
                ? GamingTheme.glowShadow(color, blur: 15, alpha: 0.3)
                : null,
      ),
      child: Column(
        children: [
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

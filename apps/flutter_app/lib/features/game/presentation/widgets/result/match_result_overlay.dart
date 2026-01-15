import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../../core/presentation/theme/gaming_theme.dart';
import '../../../../../core/presentation/theme/layout_tokens.dart';
import '../../../../../core/presentation/widgets/widgets.dart';
import 'package:tictactoe/features/rules/rules.dart';
import 'confetti_effect.dart';

/// Overlay displayed when a Best Of match is complete
class MatchResultOverlay extends StatelessWidget {
  final MatchResult matchResult;
  final Player playerX;
  final Player playerO;
  final int playerXScore;
  final int playerOScore;
  final VoidCallback? onRematch;
  final VoidCallback? onHome;

  const MatchResultOverlay({
    super.key,
    required this.matchResult,
    required this.playerX,
    required this.playerO,
    required this.playerXScore,
    required this.playerOScore,
    this.onRematch,
    this.onHome,
  });

  Player? get _winner => matchResult.when(
    ongoing: () => null,
    playerXWins: () => playerX,
    playerOWins: () => playerO,
    draw: () => null,
  );

  Color get _winnerColor => matchResult.when(
    ongoing: () => Colors.white,
    playerXWins: () => GamingTheme.xMarkColor,
    playerOWins: () => GamingTheme.oMarkColor,
    draw: () => Colors.white,
  );

  bool get _isDraw => matchResult is MatchResultDraw;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final winner = _winner;

    return Stack(
      children: [
        // Dark backdrop
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.9),
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),

        // Confetti
        if (winner != null)
          Positioned.fill(
            child: ConfettiEffect(
              primaryColor: _winnerColor,
              particleCount: 60,
            ),
          ),

        // Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy or handshake icon
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors:
                            _isDraw
                                ? [Colors.grey.shade400, Colors.grey.shade600]
                                : [
                                  GamingTheme.goldColor,
                                  GamingTheme.goldColor.withValues(alpha: 0.7),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: GamingTheme.glowShadow(
                        _isDraw ? Colors.grey : GamingTheme.goldColor,
                        blur: 40,
                        alpha: 0.7,
                      ),
                    ),
                    child: Icon(
                      _isDraw ? Icons.handshake : Icons.emoji_events,
                      color: Colors.white,
                      size: 56,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .rotate(begin: -0.02, end: 0.02, duration: 1.seconds),

              const SizedBox(height: 24),

              // Victory or Draw text
              ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors:
                              _isDraw
                                  ? [Colors.grey.shade300, Colors.white]
                                  : [_winnerColor, Colors.white],
                        ).createShader(bounds),
                    child: Text(
                      (_isDraw ? l10n.matchDraw : l10n.victory).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: Colors.white,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0)
                  .then()
                  .shimmer(duration: 2.seconds, color: Colors.white30),

              const SizedBox(height: 12),

              // Winner name with match winner message (only if there's a winner)
              if (winner != null)
                Text(
                  l10n.matchWinner(winner.name),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _winnerColor,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

              const SizedBox(height: 32),

              // Final score section
              _FinalScoreSection(
                l10n: l10n,
                playerX: playerX,
                playerO: playerO,
                playerXScore: playerXScore,
                playerOScore: playerOScore,
                matchResult: matchResult,
              ),

              const SizedBox(height: 40),

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
                          if (onRematch != null) const SizedBox(height: 12),
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
                  .fadeIn(delay: 700.ms, duration: 300.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinalScoreSection extends StatelessWidget {
  final AppLocalizations l10n;
  final Player playerX;
  final Player playerO;
  final int playerXScore;
  final int playerOScore;
  final MatchResult matchResult;

  const _FinalScoreSection({
    required this.l10n,
    required this.playerX,
    required this.playerO,
    required this.playerXScore,
    required this.playerOScore,
    required this.matchResult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          l10n.finalScore.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

        const SizedBox(height: 16),

        // Score display
        Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FinalScoreCard(
                  name: playerX.name,
                  score: playerXScore,
                  color: GamingTheme.xMarkColor,
                  isWinner: matchResult is MatchResultPlayerXWins,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                _FinalScoreCard(
                  name: playerO.name,
                  score: playerOScore,
                  color: GamingTheme.oMarkColor,
                  isWinner: matchResult is MatchResultPlayerOWins,
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
      ],
    );
  }
}

class _FinalScoreCard extends StatelessWidget {
  final String name;
  final int score;
  final Color color;
  final bool isWinner;

  const _FinalScoreCard({
    required this.name,
    required this.score,
    required this.color,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isWinner ? 0.25 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isWinner ? 0.6 : 0.2),
          width: isWinner ? 2 : 1,
        ),
        boxShadow:
            isWinner
                ? GamingTheme.glowShadow(color, blur: 20, alpha: 0.4)
                : null,
      ),
      child: Column(
        children: [
          if (isWinner)
            const Icon(Icons.star, color: GamingTheme.goldColor, size: 20)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.2, duration: 800.ms),
          if (isWinner) const SizedBox(height: 4),
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
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

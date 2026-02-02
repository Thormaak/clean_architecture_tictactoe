import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../../core/presentation/theme/gaming_theme.dart';
import '../../../../../core/presentation/theme/layout_tokens.dart';
import '../../../../../core/presentation/widgets/widgets.dart';

/// Overlay displayed when the game ends in a draw
class DrawOverlay extends StatelessWidget {
  final int moveCount;
  final VoidCallback? onRematch;
  final VoidCallback? onHome;

  const DrawOverlay({
    super.key,
    required this.moveCount,
    this.onRematch,
    this.onHome,
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
                Colors.black.withValues(alpha: 0.8),
                Colors.black.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),

        // Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handshake icon
              Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          GamingTheme.accentPurple,
                          GamingTheme.accentPink,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: GamingTheme.glowShadow(
                        GamingTheme.accentPurple,
                        blur: 30,
                        alpha: 0.6,
                      ),
                    ),
                    child: const Icon(
                      Icons.handshake,
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
                  .scaleXY(begin: 1.0, end: 1.05, duration: 1.seconds),

              const SizedBox(height: LayoutTokens.spacingLg),

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
                      l10n.drawMessage.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0)
                  .then()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2.seconds, color: Colors.white30),

              const SizedBox(height: LayoutTokens.spacingSm),

              // Move count
              Text(
                l10n.gameEndedAfterMoves(moveCount),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

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
                  .fadeIn(delay: 500.ms, duration: 300.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}

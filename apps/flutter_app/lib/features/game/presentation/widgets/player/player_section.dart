import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../../core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/features/rules/rules.dart';
import 'player_card.dart';

/// Section displaying both players with VS badge
class PlayerSection extends StatelessWidget {
  final Player playerX;
  final Player playerO;
  final PlayerMark currentTurn;
  final GameResult result;
  final bool isAIThinking;
  final GameMode gameMode;
  final int? playerXScore;
  final int? playerOScore;
  final double? maxCardWidth;

  const PlayerSection({
    super.key,
    required this.playerX,
    required this.playerO,
    required this.currentTurn,
    required this.result,
    required this.gameMode,
    this.isAIThinking = false,
    this.playerXScore,
    this.playerOScore,
    this.maxCardWidth,
  });

  PlayerMark? get winner {
    if (result case GameResultWin(:final winner)) {
      return winner;
    }
    return null;
  }

  bool get isGameOver => result is! GameResultOngoing;

  /// Returns true if the given mark represents an AI player
  bool _isPlayerAI(PlayerMark mark) {
    return gameMode.maybeWhen(
      vsAI: (_) => mark == PlayerMark.o,
      orElse: () => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isXAI = _isPlayerAI(PlayerMark.x);
    final isOAI = _isPlayerAI(PlayerMark.o);

    // Apply score overrides if provided
    final displayPlayerX =
        playerXScore != null ? playerX.copyWith(score: playerXScore!) : playerX;
    final displayPlayerO =
        playerOScore != null ? playerO.copyWith(score: playerOScore!) : playerO;

    Widget wrapCard(Widget card) {
      if (maxCardWidth == null) {
        return Expanded(child: card);
      }
      // Expanded garantit que les deux cards ont le même espace alloué
      // ConstrainedBox limite la largeur maximale
      // Center centre la card dans l'espace alloué
      return Expanded(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCardWidth!),
            child: card,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        wrapCard(
          PlayerCard(
            player: displayPlayerX,
            isActive: !isGameOver && currentTurn == PlayerMark.x,
            isThinking: isAIThinking && currentTurn == PlayerMark.x && isXAI,
            isWinner: winner == PlayerMark.x,
            isAI: isXAI,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const VsBadge(),
        ),
        wrapCard(
          PlayerCard(
            player: displayPlayerO,
            isActive: !isGameOver && currentTurn == PlayerMark.o,
            isThinking: isAIThinking && currentTurn == PlayerMark.o && isOAI,
            isWinner: winner == PlayerMark.o,
            isAI: isOAI,
          ),
        ),
      ],
    );
  }
}

/// VS badge between player cards
class VsBadge extends StatelessWidget {
  // Extracted static decorations for performance
  static const _gradient = LinearGradient(
    colors: [GamingTheme.accentPurple, GamingTheme.accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final _decoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: _gradient,
    boxShadow: GamingTheme.glowShadow(
      GamingTheme.accentPurple,
      blur: 12,
      alpha: 0.4,
    ),
  );

  static const _textStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  const VsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
          width: 48,
          height: 48,
          decoration: _decoration,
          child: Center(child: Text(l10n.versusLabel, style: _textStyle)),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }
}

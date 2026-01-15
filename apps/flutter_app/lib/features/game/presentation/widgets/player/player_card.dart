import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../../core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/features/rules/rules.dart';
import 'player_avatar.dart';

/// Card displaying player info with active/inactive states
class PlayerCard extends StatelessWidget {
  final Player player;
  final bool isActive;
  final bool isThinking;
  final bool isWinner;
  final bool isAI;

  const PlayerCard({
    super.key,
    required this.player,
    this.isActive = false,
    this.isThinking = false,
    this.isWinner = false,
    this.isAI = false,
  });

  Color get _accentColor =>
      player.mark == PlayerMark.x
          ? GamingTheme.xMarkColor
          : GamingTheme.oMarkColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget card = AnimatedContainer(
      duration: GamingTheme.turnTransitionDuration,
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GamingTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isActive || isWinner
                  ? _accentColor
                  : Colors.white.withValues(alpha: 0.1),
          width: isActive || isWinner ? 2 : 1,
        ),
        boxShadow:
            isActive || isWinner
                ? GamingTheme.glowShadow(_accentColor, blur: 20, alpha: 0.4)
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerAvatar(
            player: player,
            size: 40,
            isThinking: isThinking,
            isAI: isAI,
          ),
          const SizedBox(height: 8),
          Text(
            player.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${player.score}',
            style: TextStyle(
              color: _accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Fixed height container for status area to ensure consistent card height
          SizedBox(
            height: 14,
            child: _PlayerStatusWidget(
              l10n: l10n,
              isActive: isActive,
              isThinking: isThinking,
              accentColor: _accentColor,
            ),
          ),
        ],
      ),
    );

    // Scale animation for active state
    if (isActive) {
      card = AnimatedScale(
        scale: 1.02,
        duration: GamingTheme.turnTransitionDuration,
        child: card,
      );
    }

    // Inactive opacity
    if (!isActive && !isWinner) {
      card = AnimatedOpacity(
        opacity: 0.6,
        duration: GamingTheme.turnTransitionDuration,
        child: card,
      );
    }

    return card;
  }
}

class _PlayerStatusWidget extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isActive;
  final bool isThinking;
  final Color accentColor;

  const _PlayerStatusWidget({
    required this.l10n,
    required this.isActive,
    required this.isThinking,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive && !isThinking) {
      return Text(
        l10n.yourTurnLabel.toUpperCase(),
        style: TextStyle(
          color: accentColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      );
    }
    if (isThinking) {
      return _ThinkingDots(color: accentColor);
    }
    return const SizedBox.shrink();
  }
}

/// Animated thinking dots
class _ThinkingDots extends StatefulWidget {
  final Color color;

  const _ThinkingDots({required this.color});

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots> {
  late final List<Widget> _dots;

  @override
  void initState() {
    super.initState();
    final decoration = BoxDecoration(
      color: widget.color,
      shape: BoxShape.circle,
    );
    _dots = List.generate(3, (index) {
      return Container(
            key: ValueKey('thinking_dot_$index'),
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: decoration,
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fadeIn(delay: Duration(milliseconds: index * 200))
          .then()
          .fadeOut()
          .then()
          .fadeIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: _dots);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/features/rules/rules.dart';

/// Avatar widget for players (human or AI)
class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;
  final bool isThinking;
  final bool isAI;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 40,
    this.isThinking = false,
    this.isAI = false,
  });

  Color get _borderColor =>
      player.mark == PlayerMark.x
          ? GamingTheme.xMarkColor
          : GamingTheme.oMarkColor;

  LinearGradient get _backgroundGradient =>
      player.mark == PlayerMark.x
          ? GamingTheme.xPlayerGradient
          : GamingTheme.oPlayerGradient;

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _backgroundGradient,
        border: Border.all(color: _borderColor, width: 2),
        boxShadow: GamingTheme.glowShadow(_borderColor, blur: 8, alpha: 0.4),
      ),
      child: Center(
        child: _AvatarContent(
          player: player,
          size: size,
          isAI: isAI,
          aiIcon: _getAIIcon(),
        ),
      ),
    );

    // Add thinking animation for AI
    if (isThinking && isAI) {
      avatar = avatar
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.08,
            duration: 600.ms,
            curve: Curves.easeInOut,
          )
          .shimmer(duration: 1.seconds, color: Colors.white24);
    }

    return avatar;
  }

  IconData _getAIIcon() {
    // Different icons based on AI difficulty could be added here
    // For now, using a robot icon
    return Icons.smart_toy;
  }
}

class _AvatarContent extends StatelessWidget {
  final Player player;
  final double size;
  final bool isAI;
  final IconData aiIcon;

  const _AvatarContent({
    required this.player,
    required this.size,
    required this.isAI,
    required this.aiIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (isAI) {
      return Icon(aiIcon, color: Colors.white, size: size * 0.5);
    }

    // Human player - show initials
    final initials =
        player.name.isNotEmpty
            ? player.name.substring(0, 1).toUpperCase()
            : player.mark == PlayerMark.x
            ? 'X'
            : 'O';

    return Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.4,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

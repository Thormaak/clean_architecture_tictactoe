import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/features/rules/rules.dart';

/// Displays whose turn it is with animated text
class TurnIndicator extends StatelessWidget {
  final Player currentPlayer;
  final bool isAIThinking;
  final bool isGameOver;

  // Extracted static constants for performance
  static final _markIconBorderRadius = BorderRadius.circular(8);
  static const _baseTurnTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  const TurnIndicator({
    super.key,
    required this.currentPlayer,
    this.isAIThinking = false,
    this.isGameOver = false,
  });

  Color get _color =>
      currentPlayer.mark == PlayerMark.x
          ? GamingTheme.xMarkColor
          : GamingTheme.oMarkColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget content;
    if (isAIThinking) {
      content = _AIThinkingIndicator(l10n: l10n, color: _color);
    } else {
      content = _TurnText(
        l10n: l10n,
        currentPlayer: currentPlayer,
        color: _color,
      );
    }

    // Use AnimatedOpacity to hide when game over while preserving layout height
    return AnimatedOpacity(
      opacity: isGameOver ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey('${currentPlayer.mark}_$isAIThinking'),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: content,
        ),
      ),
    );
  }
}

class _TurnText extends StatelessWidget {
  final AppLocalizations l10n;
  final Player currentPlayer;
  final Color color;

  const _TurnText({
    required this.l10n,
    required this.currentPlayer,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Build TextStyle with shadow based on current color
    final turnTextStyle = TurnIndicator._baseTurnTextStyle.copyWith(
      shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 12)],
    );

    return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MarkIcon(mark: currentPlayer.mark, color: color),
            const SizedBox(width: 12),
            Text(l10n.yourTurn(currentPlayer.name), style: turnTextStyle),
          ],
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 2.seconds, color: color.withValues(alpha: 0.3));
  }
}

class _AIThinkingIndicator extends StatelessWidget {
  final AppLocalizations l10n;
  final Color color;

  const _AIThinkingIndicator({required this.l10n, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.psychology, color: color, size: 28)
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2.seconds),
        const SizedBox(width: 12),
        Text(l10n.aiThinking, style: TurnIndicator._baseTurnTextStyle),
        const SizedBox(width: 4),
        _AnimatedDots(color: color),
      ],
    );
  }
}

class _MarkIcon extends StatelessWidget {
  final PlayerMark mark;
  final Color color;

  const _MarkIcon({required this.mark, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: TurnIndicator._markIconBorderRadius,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          mark == PlayerMark.x ? 'X' : 'O',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  final Color color;

  const _AnimatedDots({required this.color});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> {
  // Pre-build the dot widgets once to avoid recreation on each build
  late final List<Widget> _dots;

  @override
  void initState() {
    super.initState();
    _dots = List.generate(3, (index) {
      return Text(
            '.',
            key: ValueKey('dot_$index'),
            style: TextStyle(
              color: widget.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .fadeIn(delay: Duration(milliseconds: index * 300), duration: 300.ms)
          .then(delay: 600.ms)
          .fadeOut(duration: 300.ms);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: _dots);
  }
}

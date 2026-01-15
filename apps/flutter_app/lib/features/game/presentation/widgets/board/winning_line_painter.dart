import 'package:flutter/material.dart';

import '../../../../../core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/features/rules/rules.dart';

/// Painter for the winning line overlay
class WinningLinePainter extends CustomPainter {
  final WinningLine winningLine;
  final PlayerMark winner;
  final double progress;
  final double glowIntensity;

  WinningLinePainter({
    required this.winningLine,
    required this.winner,
    required this.progress,
    this.glowIntensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    final color =
        winner == PlayerMark.x
            ? GamingTheme.xMarkColor
            : GamingTheme.oMarkColor;

    // Calculate start and end positions
    final startPos = winningLine.positions.first;
    final endPos = winningLine.positions.last;

    final startPoint = Offset(
      startPos.col * cellWidth + cellWidth / 2,
      startPos.row * cellHeight + cellHeight / 2,
    );

    final endPoint = Offset(
      endPos.col * cellWidth + cellWidth / 2,
      endPos.row * cellHeight + cellHeight / 2,
    );

    // Interpolate end point based on progress
    final currentEnd = Offset(
      startPoint.dx + (endPoint.dx - startPoint.dx) * progress,
      startPoint.dy + (endPoint.dy - startPoint.dy) * progress,
    );

    // Glow effect
    final glowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.8 * glowIntensity)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Main line
    final linePaint =
        Paint()
          ..color = color
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    canvas.drawLine(startPoint, currentEnd, glowPaint);
    canvas.drawLine(startPoint, currentEnd, linePaint);
  }

  @override
  bool shouldRepaint(WinningLinePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      glowIntensity != oldDelegate.glowIntensity ||
      winningLine != oldDelegate.winningLine;
}

/// Widget that animates the winning line
class WinningLineOverlay extends StatefulWidget {
  final WinningLine winningLine;
  final PlayerMark winner;
  final Size boardSize;

  const WinningLineOverlay({
    super.key,
    required this.winningLine,
    required this.winner,
    required this.boardSize,
  });

  @override
  State<WinningLineOverlay> createState() => _WinningLineOverlayState();
}

class _WinningLineOverlayState extends State<WinningLineOverlay>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _pulseController;
  late Animation<double> _drawAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _drawController = AnimationController(
      duration: GamingTheme.winningLineAnimationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _drawController.forward().then((_) {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _drawController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_drawAnimation, _pulseAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: widget.boardSize,
          painter: WinningLinePainter(
            winningLine: widget.winningLine,
            winner: widget.winner,
            progress: _drawAnimation.value,
            glowIntensity: _pulseAnimation.value,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/presentation/theme/gaming_theme.dart';

/// Animated X mark with neon glow effect
class XMark extends StatefulWidget {
  final double size;
  final bool animate;
  final VoidCallback? onAnimationComplete;

  const XMark({
    super.key,
    this.size = 50,
    this.animate = true,
    this.onAnimationComplete,
  });

  @override
  State<XMark> createState() => _XMarkState();
}

class _XMarkState extends State<XMark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _drawAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GamingTheme.markAnimationDuration,
      vsync: this,
    );

    _drawAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.3,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _XPainter(
              progress: _drawAnimation.value,
              color: GamingTheme.xMarkColor,
            ),
          ),
        );
      },
    );
  }
}

class _XPainter extends CustomPainter {
  final double progress;
  final Color color;

  _XPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // Glow effect
    final glowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final padding = size.width * 0.15;
    final start = padding;
    final end = size.width - padding;

    // Draw first line (top-left to bottom-right)
    final line1Progress = (progress * 2).clamp(0.0, 1.0);
    if (line1Progress > 0) {
      final line1End = Offset(
        start + (end - start) * line1Progress,
        start + (end - start) * line1Progress,
      );

      // Glow
      canvas.drawLine(Offset(start, start), line1End, glowPaint);
      // Main line
      canvas.drawLine(Offset(start, start), line1End, paint);
    }

    // Draw second line (top-right to bottom-left)
    final line2Progress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
    if (line2Progress > 0) {
      final line2End = Offset(
        end - (end - start) * line2Progress,
        start + (end - start) * line2Progress,
      );

      // Glow
      canvas.drawLine(Offset(end, start), line2End, glowPaint);
      // Main line
      canvas.drawLine(Offset(end, start), line2End, paint);
    }
  }

  @override
  bool shouldRepaint(_XPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

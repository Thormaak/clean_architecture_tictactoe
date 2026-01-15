import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/presentation/theme/gaming_theme.dart';

/// Animated O mark with neon glow effect
class OMark extends StatefulWidget {
  final double size;
  final bool animate;
  final VoidCallback? onAnimationComplete;

  const OMark({
    super.key,
    this.size = 50,
    this.animate = true,
    this.onAnimationComplete,
  });

  @override
  State<OMark> createState() => _OMarkState();
}

class _OMarkState extends State<OMark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _drawAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _drawAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _rotationAnimation = Tween<double>(
      begin: -math.pi / 2,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _OPainter(
              progress: _drawAnimation.value,
              color: GamingTheme.oMarkColor,
            ),
          ),
        );
      },
    );
  }
}

class _OPainter extends CustomPainter {
  final double progress;
  final Color color;

  _OPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.7;

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

    // Draw arc based on progress
    final sweepAngle = 2 * math.pi * progress;

    // Start from top
    const startAngle = -math.pi / 2;

    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    // Main circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_OPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

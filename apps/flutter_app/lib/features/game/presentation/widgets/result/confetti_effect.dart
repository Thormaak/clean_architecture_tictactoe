import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Simple confetti particle effect
class ConfettiEffect extends StatefulWidget {
  final Color primaryColor;
  final int particleCount;
  final Duration duration;

  const ConfettiEffect({
    super.key,
    required this.primaryColor,
    this.particleCount = 40,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3,
        vx: (_random.nextDouble() - 0.5) * 0.02,
        vy: _random.nextDouble() * 0.01 + 0.005,
        size: _random.nextDouble() * 8 + 4,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        color: _getRandomColor(),
      ),
    );

    _controller.forward();
  }

  Color _getRandomColor() {
    final colors = [
      widget.primaryColor,
      Colors.white,
      const Color(0xFFFFD700), // Gold
      widget.primaryColor.withValues(alpha: 0.7),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates repaints to this widget only
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  final double size;
  double rotation;
  final double rotationSpeed;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Update position based on progress
      final t = progress;
      final gravity = 0.015;

      final x = particle.x + particle.vx * t * 100;
      final y = particle.y + particle.vy * t * 100 + gravity * t * t * 100;
      final rotation = particle.rotation + particle.rotationSpeed * t * 100;

      // Skip if out of bounds
      if (y > 1.2) continue;

      // Calculate opacity (fade out towards the end)
      final opacity = (1 - progress).clamp(0.0, 1.0);

      final paint =
          Paint()
            ..color = particle.color.withValues(alpha: opacity)
            ..style = PaintingStyle.fill;

      final px = x * size.width;
      final py = y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rotation);

      // Draw rectangle particle
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

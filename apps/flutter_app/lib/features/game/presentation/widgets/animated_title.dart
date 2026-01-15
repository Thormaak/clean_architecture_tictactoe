import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/extensions/build_context_extensions.dart';
import '../../../../core/presentation/theme/gaming_theme.dart';

/// Animated title with gradient, glow effect, and multiple animations
class AnimatedTitle extends StatelessWidget {
  final String title;

  const AnimatedTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final fontSize = context.isLargeScreen ? 68.0 : 56.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect layer (behind the text) - multiple layers for depth
        ...List.generate(3, (index) {
          return Text(
                title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color:
                      [
                        GamingTheme.accentCyan.withValues(alpha: 0.4),
                        GamingTheme.accentPurple.withValues(alpha: 0.3),
                        GamingTheme.accentPink.withValues(alpha: 0.2),
                      ][index],
                  shadows: [
                    Shadow(
                      color: [
                        GamingTheme.accentCyan,
                        GamingTheme.accentPurple,
                        GamingTheme.accentPink,
                      ][index].withValues(alpha: 0.6),
                      blurRadius: [25.0, 35.0, 45.0][index],
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: Offset(1.03 + (index * 0.01), 1.03 + (index * 0.01)),
                duration: (2.0 + (index * 0.3)).seconds,
                curve: Curves.easeInOut,
              );
        }),

        // Main text with gradient
        ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [
                      GamingTheme.accentCyan,
                      GamingTheme.accentPurple,
                      GamingTheme.accentPink,
                      GamingTheme.accentCyan,
                    ],
                    stops: const [0.0, 0.33, 0.66, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: Colors.white,
                  shadows: [
                    // Subtle shadow for depth
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.2, end: 0)
            .then()
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(
              duration: 2.5.seconds,
              color: Colors.white.withValues(alpha: 0.5),
              angle: 0.5,
            ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/audio/audio_controller.dart';

/// Gaming-style gradient card for selection options (game modes, difficulty, etc.)
///
/// Features:
/// - Gradient background with glow shadow
/// - Icon container with title and subtitle
/// - Optional trailing widget (defaults to chevron)
/// - Optional breathing animation (enabled by default)
///
/// Note: Entrance animations (fadeIn, slideX, delay) should be applied by the parent.
class GamingGradientCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;
  final Widget? trailing;
  final double borderRadius;
  final EdgeInsets padding;
  final bool enableBreathingAnimation;
  final bool enableClickSound;

  const GamingGradientCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.trailing,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(20),
    this.enableBreathingAnimation = true,
    this.enableClickSound = true,
  });

  void _handleTap(BuildContext context) {
    if (enableClickSound) {
      ProviderScope.containerOf(
        context,
      ).read(audioControllerProvider).playSfx(SfxType.click);
    }
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: _getGradientFirstColor().withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
            ],
          ),
        ),
      ),
    );

    if (!enableBreathingAnimation) {
      return card;
    }

    return card
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 1,
          end: 1.02,
          duration: 2.seconds,
          curve: Curves.easeInOut,
        );
  }

  Color _getGradientFirstColor() {
    if (gradient is LinearGradient) {
      return (gradient as LinearGradient).colors.first;
    }
    if (gradient is RadialGradient) {
      return (gradient as RadialGradient).colors.first;
    }
    return Colors.purple;
  }
}

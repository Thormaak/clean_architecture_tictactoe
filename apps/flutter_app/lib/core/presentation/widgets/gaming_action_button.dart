import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/gaming_theme.dart';
import '../../application/audio/audio_controller.dart';

/// Variant style for GamingActionButton
enum GamingActionButtonVariant {
  /// Filled button with gradient background
  filled,

  /// Outlined button with transparent background and colored border
  outlined,
}

/// Gaming-style action button for overlays and dialogs
///
/// Features:
/// - Two variants: filled (with gradient) or outlined (with border)
/// - Icon + label layout
/// - Press scale animation (0.95)
/// - Glow shadow for filled variant
///
/// Note: Entrance animations (fadeIn, slideY, delay) should be applied by the parent.
class GamingActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final GamingActionButtonVariant variant;
  final Color? color;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsets padding;
  final bool enableClickSound;

  const GamingActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.variant = GamingActionButtonVariant.outlined,
    this.color,
    this.gradient,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.enableClickSound = true,
  });

  /// Creates a filled button with gradient background
  const GamingActionButton.filled({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.color,
    this.gradient,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.enableClickSound = true,
  }) : variant = GamingActionButtonVariant.filled;

  /// Creates an outlined button with border
  const GamingActionButton.outlined({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.color,
    this.gradient,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.enableClickSound = true,
  }) : variant = GamingActionButtonVariant.outlined;

  @override
  State<GamingActionButton> createState() => _GamingActionButtonState();
}

class _GamingActionButtonState extends State<GamingActionButton> {
  bool _isPressed = false;

  Color get _effectiveColor => widget.color ?? GamingTheme.accentPurple;

  bool get _isFilled => widget.variant == GamingActionButtonVariant.filled;

  Gradient? get _effectiveGradient {
    if (!_isFilled) return null;
    if (widget.gradient != null) return widget.gradient;
    return LinearGradient(
      colors: [_effectiveColor, _effectiveColor.withValues(alpha: 0.8)],
    );
  }

  void _handleTap(BuildContext context) {
    if (widget.enableClickSound) {
      ProviderScope.containerOf(
        context,
      ).read(audioControllerProvider).playSfx(SfxType.click);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : null;

        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () => _handleTap(context),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: containerWidth,
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: _effectiveGradient,
                color: _isFilled ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border:
                    _isFilled
                        ? null
                        : Border.all(color: _effectiveColor, width: 1.5),
                boxShadow:
                    _isFilled
                        ? GamingTheme.glowShadow(
                          _effectiveColor,
                          blur: 16,
                          alpha: 0.4,
                        )
                        : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: _isFilled ? Colors.white : _effectiveColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: _isFilled ? Colors.white : _effectiveColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

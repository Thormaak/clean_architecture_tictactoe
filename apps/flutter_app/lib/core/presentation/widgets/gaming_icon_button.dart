import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/gaming_theme.dart';
import '../../application/audio/audio_controller.dart';

/// Variant style for GamingIconButton
enum GamingIconButtonVariant {
  /// Outlined button with transparent/semi-transparent background and colored border
  outlined,

  /// Filled button with gradient background
  filled,
}

/// Shape for GamingIconButton
enum GamingIconButtonShape {
  /// Circular button
  circle,

  /// Square button with rounded corners
  square,
}

/// Gaming-style icon button for controls, navigation, and actions
///
/// Features:
/// - Two shapes: circle or square (with rounded corners)
/// - Two variants: filled (with gradient) or outlined (with border)
/// - Press scale animation (0.9) with glow shadow changes
/// - Optional icon rotation animation on tap
/// - Optional breathing animation (for restart button when game over)
/// - Disabled state support
///
/// Note: Entrance animations should be applied by the parent if needed.
class GamingIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final GamingIconButtonVariant variant;
  final GamingIconButtonShape shape;
  final double? size;
  final double iconSize;
  final Color color;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool enableIconRotation;
  final double rotationTurns;
  final Duration rotationDuration;
  final bool enableBreathingAnimation;
  final bool enableClickSound;

  const GamingIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.variant = GamingIconButtonVariant.outlined,
    this.shape = GamingIconButtonShape.circle,
    this.size,
    this.iconSize = 24,
    this.color = GamingTheme.accentCyan,
    this.gradient,
    this.backgroundColor,
    this.enableIconRotation = false,
    this.rotationTurns = -0.125,
    this.rotationDuration = const Duration(milliseconds: 300),
    this.enableBreathingAnimation = false,
    this.enableClickSound = true,
  });

  /// Creates an outlined circular button (for control buttons like undo/settings)
  const GamingIconButton.control({
    super.key,
    required this.icon,
    this.onTap,
    this.color = GamingTheme.accentCyan,
    this.enableIconRotation = false,
    this.rotationTurns = -0.125,
    this.rotationDuration = const Duration(milliseconds: 300),
    this.enableClickSound = true,
  }) : variant = GamingIconButtonVariant.outlined,
       shape = GamingIconButtonShape.circle,
       size = 50,
       iconSize = 24,
       gradient = null,
       backgroundColor = null,
       enableBreathingAnimation = false;

  /// Creates a filled circular button with gradient (for restart button)
  const GamingIconButton.restart({
    super.key,
    required this.onTap,
    this.enableBreathingAnimation = false,
    this.enableIconRotation = true,
    this.enableClickSound = true,
  }) : icon = Icons.refresh_rounded,
       variant = GamingIconButtonVariant.filled,
       shape = GamingIconButtonShape.circle,
       size = 60,
       iconSize = 28,
       color = GamingTheme.accentPurple,
       gradient = GamingTheme.primaryGradient,
       backgroundColor = null,
       rotationTurns = 1.0,
       rotationDuration = const Duration(milliseconds: 500);

  /// Creates an outlined square button (for header buttons like back/menu)
  const GamingIconButton.header({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = GamingTheme.accentCyan,
    this.enableClickSound = true,
  }) : variant = GamingIconButtonVariant.outlined,
       shape = GamingIconButtonShape.square,
       size = 44,
       iconSize = 20,
       gradient = null,
       backgroundColor = null,
       enableIconRotation = false,
       rotationTurns = 0,
       rotationDuration = const Duration(milliseconds: 300),
       enableBreathingAnimation = false;

  @override
  State<GamingIconButton> createState() => _GamingIconButtonState();
}

class _GamingIconButtonState extends State<GamingIconButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _rotationController;

  bool get _isDisabled => widget.onTap == null;
  bool get _isFilled => widget.variant == GamingIconButtonVariant.filled;
  bool get _isCircle => widget.shape == GamingIconButtonShape.circle;

  double get _effectiveSize {
    if (widget.size != null) return widget.size!;
    return _isCircle ? 50 : 44;
  }

  Color? get _effectiveBackgroundColor {
    if (_isFilled) return null; // Uses gradient instead
    if (widget.backgroundColor != null) return widget.backgroundColor;
    // Square buttons get semi-transparent card background
    if (!_isCircle) return GamingTheme.cardBackground.withValues(alpha: 0.6);
    return Colors.transparent;
  }

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: widget.rotationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context) {
    if (widget.enableIconRotation) {
      _rotationController.forward(from: 0);
    }
    if (widget.enableClickSound) {
      ProviderScope.containerOf(
        context,
      ).read(audioControllerProvider).playSfx(SfxType.click);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: _isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: _isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel:
          _isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: _isDisabled ? null : () => _handleTap(context),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isDisabled ? 0.3 : 1.0,
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: _GamingIconButtonContainer(
            size: _effectiveSize,
            isFilled: _isFilled,
            isCircle: _isCircle,
            isDisabled: _isDisabled,
            isPressed: _isPressed,
            gradient: widget.gradient,
            backgroundColor: _effectiveBackgroundColor,
            color: widget.color,
            child: Center(
              child: _GamingIcon(
                icon: widget.icon,
                isFilled: _isFilled,
                color: widget.color,
                iconSize: widget.iconSize,
                enableIconRotation: widget.enableIconRotation,
                rotationController: _rotationController,
                rotationTurns: widget.rotationTurns,
              ),
            ),
          ),
        ),
      ),
    );

    // Add breathing animation if enabled
    if (widget.enableBreathingAnimation && !_isDisabled) {
      button = button
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.05,
            duration: 1.seconds,
            curve: Curves.easeInOut,
          );
    }

    return button;
  }
}

class _GamingIconButtonContainer extends StatelessWidget {
  final double size;
  final bool isFilled;
  final bool isCircle;
  final bool isDisabled;
  final bool isPressed;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color color;
  final Widget child;

  const _GamingIconButtonContainer({
    required this.size,
    required this.isFilled,
    required this.isCircle,
    required this.isDisabled,
    required this.isPressed,
    required this.gradient,
    required this.backgroundColor,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: isFilled ? (gradient ?? GamingTheme.primaryGradient) : null,
        color: backgroundColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(12),
        border: isFilled ? null : Border.all(color: color, width: 1.5),
        boxShadow: _resolveBoxShadow(),
      ),
      child: child,
    );
  }

  List<BoxShadow>? _resolveBoxShadow() {
    if (isDisabled) return null;

    if (isFilled) {
      return [
        BoxShadow(
          color: color.withValues(alpha: 0.5),
          blurRadius: isPressed ? 20 : 16,
          spreadRadius: isPressed ? 2 : 0,
        ),
      ];
    }

    // Outlined variant: glow shadow on press or for square buttons (always visible)
    if (isCircle) {
      return isPressed
          ? GamingTheme.glowShadow(color, blur: 12, alpha: 0.4)
          : null;
    }

    // Square buttons always have glow shadow (intensity changes on press)
    return GamingTheme.glowShadow(
      color,
      blur: isPressed ? 12 : 8,
      alpha: isPressed ? 0.4 : 0.2,
    );
  }
}

class _GamingIcon extends StatelessWidget {
  final IconData icon;
  final bool isFilled;
  final Color color;
  final double iconSize;
  final bool enableIconRotation;
  final AnimationController rotationController;
  final double rotationTurns;

  const _GamingIcon({
    required this.icon,
    required this.isFilled,
    required this.color,
    required this.iconSize,
    required this.enableIconRotation,
    required this.rotationController,
    required this.rotationTurns,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      color: isFilled ? Colors.white : color,
      size: iconSize,
    );

    if (!enableIconRotation) {
      return iconWidget;
    }

    return RotationTransition(
      turns: Tween(begin: 0.0, end: rotationTurns).animate(
        CurvedAnimation(parent: rotationController, curve: Curves.easeOut),
      ),
      child: iconWidget,
    );
  }
}

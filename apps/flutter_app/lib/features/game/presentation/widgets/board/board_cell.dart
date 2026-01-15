import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/features/rules/rules.dart';
import 'o_mark.dart';
import 'x_mark.dart';

/// A single cell on the game board
class BoardCell extends StatefulWidget {
  final Cell cell;
  final bool isWinningCell;
  final bool isGameOver;
  final PlayerMark? currentPlayerMark;
  final VoidCallback? onTap;
  final bool animateMark;

  const BoardCell({
    super.key,
    required this.cell,
    this.isWinningCell = false,
    this.isGameOver = false,
    this.currentPlayerMark,
    this.onTap,
    this.animateMark = true,
  });

  @override
  State<BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell>
    with SingleTickerProviderStateMixin {
  // Extracted static border radius for performance
  static final _cellBorderRadius = BorderRadius.circular(12);

  bool _isPressed = false;

  Color get _hoverColor {
    if (widget.currentPlayerMark == PlayerMark.x) {
      return GamingTheme.xMarkColor.withValues(alpha: 0.1);
    }
    return GamingTheme.oMarkColor.withValues(alpha: 0.1);
  }

  Color get _winningHighlightColor {
    if (widget.cell.mark == PlayerMark.x) {
      return GamingTheme.xMarkColor.withValues(alpha: 0.15);
    }
    return GamingTheme.oMarkColor.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    Widget cellContent = Center(
      child: _BoardCellMark(cell: widget.cell, animateMark: widget.animateMark),
    );

    // Apply winning cell highlight
    if (widget.isWinningCell && widget.cell.isOccupied) {
      cellContent = Container(
            decoration: BoxDecoration(
              color: _winningHighlightColor,
              borderRadius: _cellBorderRadius,
            ),
            child: cellContent,
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.05,
            duration: 800.ms,
            curve: Curves.easeInOut,
          );
    }

    // Apply dimming for non-winning cells when game is over with a winner
    if (widget.isGameOver && !widget.isWinningCell && widget.cell.isOccupied) {
      cellContent = Opacity(opacity: 0.4, child: cellContent);
    }

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color:
                _isPressed && widget.cell.isEmpty && widget.onTap != null
                    ? _hoverColor
                    : null,
            borderRadius: _cellBorderRadius,
          ),
          child: cellContent,
        ),
      ),
    );
  }
}

class _BoardCellMark extends StatelessWidget {
  final Cell cell;
  final bool animateMark;

  const _BoardCellMark({required this.cell, required this.animateMark});

  @override
  Widget build(BuildContext context) {
    if (cell.isEmpty) {
      return const SizedBox.shrink();
    }

    const markSize = 50.0;

    if (cell.mark == PlayerMark.x) {
      return XMark(size: markSize, animate: animateMark);
    } else {
      return OMark(size: markSize, animate: animateMark);
    }
  }
}

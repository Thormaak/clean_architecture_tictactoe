import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/features/rules/rules.dart';
import 'board/o_mark.dart';
import 'board/x_mark.dart';

/// Decorative mini board for the home screen
/// Shows a small preview of the game with some X and O marks
class DecorativeMiniBoard extends StatelessWidget {
  const DecorativeMiniBoard({super.key});

  /// Creates a decorative board state with some moves
  Board _createDecorativeBoard() {
    // Create a board with a balanced pattern showing both players
    // Pattern: X-O-X on top, O in center, X-O diagonal
    // This creates an interesting visual that shows active gameplay
    return Board.empty()
        .withMove(Position(row: 0, col: 0), PlayerMark.x)
        .withMove(Position(row: 0, col: 1), PlayerMark.o)
        .withMove(Position(row: 0, col: 2), PlayerMark.x)
        .withMove(Position(row: 1, col: 1), PlayerMark.o)
        .withMove(Position(row: 2, col: 0), PlayerMark.x)
        .withMove(Position(row: 2, col: 2), PlayerMark.o);
  }

  @override
  Widget build(BuildContext context) {
    final board = _createDecorativeBoard();
    final boardSize = 180.0; // Smaller size for decorative purpose

    return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: GamingTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GamingTheme.accentPurple.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GamingTheme.accentPurple.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: GamingTheme.accentCyan.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Grid lines
                CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: _MiniGridPainter(),
                ),

                // Cells
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                        ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final cell = board.cells[index];
                      return _MiniBoardCell(
                        cell: cell,
                        markSize: 30.0, // Smaller size for mini board
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .then()
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 3.seconds,
          color: GamingTheme.accentCyan.withValues(alpha: 0.1),
        );
  }
}

/// Paints the grid lines for the mini board
class _MiniGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    // Glow paint
    final glowPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              GamingTheme.accentCyan.withValues(alpha: 0.25),
              GamingTheme.accentPurple.withValues(alpha: 0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Main line paint
    final linePaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              GamingTheme.accentCyan.withValues(alpha: 0.4),
              GamingTheme.accentPurple.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..strokeWidth = 1.5;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = cellWidth * i;
      canvas.drawLine(Offset(x, 6), Offset(x, size.height - 6), glowPaint);
      canvas.drawLine(Offset(x, 6), Offset(x, size.height - 6), linePaint);
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = cellHeight * i;
      canvas.drawLine(Offset(6, y), Offset(size.width - 6, y), glowPaint);
      canvas.drawLine(Offset(6, y), Offset(size.width - 6, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_MiniGridPainter oldDelegate) => false;
}

/// Simplified cell widget for decorative mini board
class _MiniBoardCell extends StatelessWidget {
  final Cell cell;
  final double markSize;

  const _MiniBoardCell({required this.cell, required this.markSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Center(child: _MiniBoardMark(cell: cell, markSize: markSize)),
    );
  }
}

class _MiniBoardMark extends StatelessWidget {
  final Cell cell;
  final double markSize;

  const _MiniBoardMark({required this.cell, required this.markSize});

  @override
  Widget build(BuildContext context) {
    if (cell.isEmpty) {
      return const SizedBox.shrink();
    }

    if (cell.mark == PlayerMark.x) {
      return XMark(size: markSize, animate: false);
    } else {
      return OMark(size: markSize, animate: false);
    }
  }
}

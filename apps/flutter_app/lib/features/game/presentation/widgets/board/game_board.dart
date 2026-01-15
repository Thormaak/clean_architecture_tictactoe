import 'package:flutter/material.dart';

import '../../../../../core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/features/rules/rules.dart';
import 'board_cell.dart';
import 'winning_line_painter.dart';

/// The main game board widget with 3x3 grid
class GameBoard extends StatelessWidget {
  final Board board;
  final GameResult result;
  final PlayerMark currentTurn;
  final ValueChanged<Position>? onCellTap;
  final Set<int> animatedCells;

  // Extracted static decoration for performance
  static final _boardDecoration = BoxDecoration(
    color: GamingTheme.cardBackground,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: GamingTheme.accentPurple.withValues(alpha: 0.4),
      width: 2,
    ),
    boxShadow: GamingTheme.boardShadow,
  );

  static final _clipBorderRadius = BorderRadius.circular(18);

  const GameBoard({
    super.key,
    required this.board,
    required this.result,
    required this.currentTurn,
    this.onCellTap,
    this.animatedCells = const {},
  });

  bool get isGameOver => result is! GameResultOngoing;

  /// Computes winning cell indices once per build
  Set<int> _computeWinningIndices() {
    if (result case GameResultWin(:final winningLine)) {
      return winningLine.positions.map((p) => p.index).toSet();
    }
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    // Pre-compute winning indices once
    final winningIndices = _computeWinningIndices();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.maxWidth >= 480 ? 480.0 : 360.0;
        final boardSize = constraints.maxWidth.clamp(280.0, maxSize);

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: _boardDecoration,
          child: ClipRRect(
            borderRadius: _clipBorderRadius,
            child: Stack(
              children: [
                // Grid lines
                CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: _GridPainter(),
                ),

                // Cells
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final cell = board.cells[index];
                      final isWinningCell = winningIndices.contains(index);
                      final shouldAnimate = !animatedCells.contains(index);

                      return BoardCell(
                        key: ValueKey('cell_${cell.position.index}'),
                        cell: cell,
                        isWinningCell: isWinningCell,
                        isGameOver: isGameOver,
                        currentPlayerMark: currentTurn,
                        animateMark: shouldAnimate,
                        onTap:
                            onCellTap == null
                                ? null
                                : () => onCellTap?.call(cell.position),
                      );
                    },
                  ),
                ),

                // Winning line overlay
                if (result case GameResultWin(
                  :final winner,
                  :final winningLine,
                ))
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: WinningLineOverlay(
                        winningLine: winningLine,
                        winner: winner,
                        boardSize: Size(boardSize - 16, boardSize - 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Paints the grid lines with neon glow effect
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    // Glow paint
    final glowPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              GamingTheme.accentCyan.withValues(alpha: 0.3),
              GamingTheme.accentPurple.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Main line paint
    final linePaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              GamingTheme.accentCyan.withValues(alpha: 0.5),
              GamingTheme.accentPurple.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..strokeWidth = 2;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = cellWidth * i;
      canvas.drawLine(Offset(x, 8), Offset(x, size.height - 8), glowPaint);
      canvas.drawLine(Offset(x, 8), Offset(x, size.height - 8), linePaint);
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = cellHeight * i;
      canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), glowPaint);
      canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

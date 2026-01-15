import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  group('Position - UNIT-POS', () {
    group('index conversion', () {
      test('[P1] UNIT-POS-001: should convert row/col to correct index', () {
        // Arrange & Act & Assert
        expect(const Position(row: 0, col: 0).index, 0);
        expect(const Position(row: 0, col: 1).index, 1);
        expect(const Position(row: 0, col: 2).index, 2);
        expect(const Position(row: 1, col: 0).index, 3);
        expect(const Position(row: 1, col: 1).index, 4);
        expect(const Position(row: 1, col: 2).index, 5);
        expect(const Position(row: 2, col: 0).index, 6);
        expect(const Position(row: 2, col: 1).index, 7);
        expect(const Position(row: 2, col: 2).index, 8);
      });

      test('[P1] UNIT-POS-002: should create Position from index', () {
        // Arrange & Act & Assert
        for (int i = 0; i < 9; i++) {
          final pos = Position.fromIndex(i);
          expect(pos.index, i);
        }
      });

      test('[P1] UNIT-POS-003: fromIndex should produce correct row/col', () {
        // Arrange & Act & Assert
        expect(Position.fromIndex(0), const Position(row: 0, col: 0));
        expect(Position.fromIndex(4), const Position(row: 1, col: 1));
        expect(Position.fromIndex(8), const Position(row: 2, col: 2));
      });
    });

    group('isValid', () {
      test('[P1] UNIT-POS-004: should return true for valid positions', () {
        // Arrange & Act & Assert
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            expect(Position(row: row, col: col).isValid, true);
          }
        }
      });

      test('[P1] UNIT-POS-005: should return false for negative row', () {
        // Arrange & Act & Assert
        expect(const Position(row: -1, col: 0).isValid, false);
      });

      test('[P1] UNIT-POS-006: should return false for negative col', () {
        // Arrange & Act & Assert
        expect(const Position(row: 0, col: -1).isValid, false);
      });

      test('[P1] UNIT-POS-007: should return false for row >= 3', () {
        // Arrange & Act & Assert
        expect(const Position(row: 3, col: 0).isValid, false);
        expect(const Position(row: 10, col: 0).isValid, false);
      });

      test('[P1] UNIT-POS-008: should return false for col >= 3', () {
        // Arrange & Act & Assert
        expect(const Position(row: 0, col: 3).isValid, false);
        expect(const Position(row: 0, col: 10).isValid, false);
      });
    });

    group('equality', () {
      test('[P2] UNIT-POS-009: should be equal for same row and col', () {
        // Arrange & Act & Assert
        expect(const Position(row: 1, col: 2), const Position(row: 1, col: 2));
      });

      test(
        '[P2] UNIT-POS-010: should not be equal for different positions',
        () {
          // Arrange & Act & Assert
          expect(
            const Position(row: 1, col: 2) == const Position(row: 2, col: 1),
            false,
          );
        },
      );
    });
  });
}

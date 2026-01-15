import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  group('BestOf - UNIT-BO', () {
    group('roundsToWin', () {
      test('[P1] UNIT-BO-001: should return 1 for BO1', () {
        // Arrange & Act & Assert
        expect(BestOf.bo1.roundsToWin, 1);
      });

      test('[P1] UNIT-BO-002: should return 2 for BO3', () {
        // Arrange & Act & Assert
        expect(BestOf.bo3.roundsToWin, 2);
      });

      test('[P1] UNIT-BO-003: should return 3 for BO5', () {
        // Arrange & Act & Assert
        expect(BestOf.bo5.roundsToWin, 3);
      });
    });

    group('maxRounds', () {
      test('[P1] UNIT-BO-004: should return 1 for BO1', () {
        // Arrange & Act & Assert
        expect(BestOf.bo1.maxRounds, 1);
      });

      test('[P1] UNIT-BO-005: should return 3 for BO3', () {
        // Arrange & Act & Assert
        expect(BestOf.bo3.maxRounds, 3);
      });

      test('[P1] UNIT-BO-006: should return 5 for BO5', () {
        // Arrange & Act & Assert
        expect(BestOf.bo5.maxRounds, 5);
      });
    });
  });
}

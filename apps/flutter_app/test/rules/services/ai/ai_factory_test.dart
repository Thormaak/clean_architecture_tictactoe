import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  group('AIPlayerFactory - UNIT-AIF', () {
    test(
      '[P1] UNIT-AIF-001: should create ProbabilisticAIPlayer for all difficulties',
      () {
        for (final difficulty in AIDifficulty.values) {
          final ai = AIPlayerFactory.create(difficulty);

          expect(
            ai,
            isA<ProbabilisticAIPlayer>(),
            reason:
                'Factory should return ProbabilisticAIPlayer for $difficulty',
          );
        }
      },
    );

    test(
      '[P1] UNIT-AIF-002: should create AI that can compute moves for all difficulties',
      () async {
        final playerX = const Player(
          id: 'human',
          name: 'Human',
          mark: PlayerMark.x,
        );
        final playerO = const Player(id: 'ai', name: 'AI', mark: PlayerMark.o);

        final state = GameState(
          gameId: 'test',
          config: GameConfig(
            mode: const GameMode.vsAI(),
            playerX: playerX,
            playerO: playerO,
          ),
          board: Board.empty(),
          currentTurn: PlayerMark.o,
          moveHistory: const [],
          result: const GameResult.ongoing(),
          startedAt: DateTime.now(),
        );

        for (final difficulty in AIDifficulty.values) {
          final ai = AIPlayerFactory.create(difficulty);
          final move = await ai.computeMove(state);

          expect(
            move.isValid,
            true,
            reason: 'AI $difficulty should return valid move',
          );
          expect(
            state.board.isPositionEmpty(move),
            true,
            reason: 'AI $difficulty should return empty position',
          );
        }
      },
    );
  });
}

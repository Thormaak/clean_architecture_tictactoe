/// Best Of configuration for matches
enum BestOf {
  /// Single game match
  bo1(roundsToWin: 1),

  /// Best of 3 - first to 2 wins
  bo3(roundsToWin: 2),

  /// Best of 5 - first to 3 wins
  bo5(roundsToWin: 3);

  /// Number of rounds needed to win the match
  final int roundsToWin;

  const BestOf({required this.roundsToWin});

  /// Maximum possible rounds (if all rounds needed)
  int get maxRounds => (roundsToWin * 2) - 1;
}

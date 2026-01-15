// Domain entities
export 'domain/entities/board.dart';
export 'domain/entities/game_state.dart';
export 'domain/entities/match_state.dart';
export 'domain/entities/player.dart';

// Domain value objects
export 'domain/value_objects/best_of.dart';
export 'domain/value_objects/game_config.dart';
export 'domain/value_objects/game_mode.dart';
export 'domain/value_objects/game_result.dart';
export 'domain/value_objects/match_result.dart';
export 'domain/value_objects/move.dart';
export 'domain/value_objects/position.dart';
export 'domain/value_objects/validation.dart';

// Domain extensions
export 'domain/extensions/game_mode_extensions.dart';
export 'domain/extensions/game_state_extensions.dart';

// Services
export 'services/game_engine.dart';
export 'services/match_engine.dart';
export 'services/move_validator.dart';
export 'services/win_detector.dart';

// AI
export 'services/ai/ai_factory.dart';
export 'services/ai/ai_player.dart';
export 'services/ai/probabilistic_ai.dart';

// Strategies
export 'strategies/player_strategy.dart';
export 'strategies/ai_player_strategy.dart';
export 'strategies/human_player_strategy.dart';
export 'strategies/strategy_factory.dart';

// Factories
export 'factories/game_factory.dart';

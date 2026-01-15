import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/di/settings_repository_providers.dart';
import '../../application/use_cases/get_audio_settings_use_case.dart';
import '../../application/use_cases/set_audio_settings_use_case.dart';

// =============================================================================
// Application Layer - Use Cases
// =============================================================================

/// Get audio settings use case provider
final getAudioSettingsUseCaseProvider = Provider<GetAudioSettingsUseCase>((
  ref,
) {
  return GetAudioSettingsUseCase(ref.read(audioSettingsRepositoryProvider));
});

/// Set audio settings use case provider
final setAudioSettingsUseCaseProvider = Provider<SetAudioSettingsUseCase>((
  ref,
) {
  return SetAudioSettingsUseCase(ref.read(audioSettingsRepositoryProvider));
});

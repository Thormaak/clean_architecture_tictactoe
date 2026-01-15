import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/domain/repositories/i_audio_settings_repository.dart';
import '../../../features/settings/domain/repositories/i_locale_repository.dart';
import '../../../features/settings/infrastructure/repositories/audio_settings_repository_impl.dart';
import '../../../features/settings/infrastructure/repositories/locale_repository_impl.dart';
import 'shared_preferences_provider.dart';

// =============================================================================
// Infrastructure Layer - Repositories (DI)
// =============================================================================

/// Locale repository provider
final localeRepositoryProvider = Provider<ILocaleRepository>((ref) {
  return LocaleRepositoryImpl(ref.read(sharedPreferencesProvider));
});

/// Audio settings repository provider
final audioSettingsRepositoryProvider = Provider<IAudioSettingsRepository>((
  ref,
) {
  return AudioSettingsRepositoryImpl(ref.read(sharedPreferencesProvider));
});

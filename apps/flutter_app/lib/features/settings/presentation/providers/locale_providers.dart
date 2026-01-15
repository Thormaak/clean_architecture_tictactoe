import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/di/settings_repository_providers.dart';
import '../../application/use_cases/get_locale_use_case.dart';
import '../../application/use_cases/set_locale_use_case.dart';

// =============================================================================
// Application Layer - Use Cases
// =============================================================================

/// Get locale use case provider
final getLocaleUseCaseProvider = Provider<GetLocaleUseCase>((ref) {
  return GetLocaleUseCase(ref.read(localeRepositoryProvider));
});

/// Set locale use case provider
final setLocaleUseCaseProvider = Provider<SetLocaleUseCase>((ref) {
  return SetLocaleUseCase(ref.read(localeRepositoryProvider));
});

import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../../../core/presentation/l10n/app_locale_mapper.dart';
import '../../application/use_cases/get_locale_use_case.dart';
import '../../application/use_cases/set_locale_use_case.dart';
import 'locale_providers.dart';

part 'locale_provider.g.dart';

/// Supported locales for the app
const supportedLocales = [Locale('en'), Locale('fr')];

/// Notifier that manages the current app locale
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  late final GetLocaleUseCase _getLocaleUseCase;
  late final SetLocaleUseCase _setLocaleUseCase;

  @override
  Future<Locale?> build() async {
    _getLocaleUseCase = ref.read(getLocaleUseCaseProvider);
    _setLocaleUseCase = ref.read(setLocaleUseCaseProvider);

    // Load saved locale - Riverpod gère automatiquement loading/error states
    final result = await _getLocaleUseCase.call(const NoParams());
    return result.fold(
      (locale) => flutterLocaleFromApp(locale),
      (_) => null, // Use system locale on error
    );
  }

  /// Set the app locale
  Future<void> setLocale(Locale locale) async {
    final previousValue =
        await future; // Récupère la valeur actuelle (peut être null)
    if (previousValue?.languageCode == locale.languageCode) {
      return;
    }
    state = const AsyncValue.loading();
    final appLocale = appLocaleFromFlutter(locale);
    final result = await _setLocaleUseCase.call(appLocale);
    result.fold(
      (unit) => state = AsyncValue.data(locale),
      (_) =>
          state =
              previousValue != null
                  ? AsyncValue.data(previousValue)
                  : AsyncValue.data(null),
    );
  }

  /// Toggle between English and French
  Future<void> toggleLocale() async {
    final currentLocale =
        await future; // Récupère la valeur actuelle (peut être null)
    final newLocale =
        currentLocale?.languageCode == 'fr'
            ? const Locale('en')
            : const Locale('fr');
    await setLocale(newLocale);
  }
}

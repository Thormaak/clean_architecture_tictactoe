import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/core/application/usecases/use_case.dart';
import 'package:tictactoe/features/settings/presentation/providers/locale_provider.dart';
import 'package:tictactoe/features/settings/presentation/providers/locale_providers.dart';
import 'package:tictactoe/features/settings/application/use_cases/get_locale_use_case.dart';
import 'package:tictactoe/features/settings/application/use_cases/set_locale_use_case.dart';
import 'package:tictactoe/features/settings/domain/entities/app_locale.dart';
import 'package:tictactoe/features/settings/domain/failures/locale_repository_failures.dart';

class MockGetLocaleUseCase extends Mock implements GetLocaleUseCase {}

class MockSetLocaleUseCase extends Mock implements SetLocaleUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(AppLocale.fr);
    registerFallbackValue(const NoParams());
  });

  group('LocaleNotifier - UNIT-LN', () {
    late ProviderContainer container;
    late MockGetLocaleUseCase mockGetLocaleUseCase;
    late MockSetLocaleUseCase mockSetLocaleUseCase;

    setUp(() {
      mockGetLocaleUseCase = MockGetLocaleUseCase();
      mockSetLocaleUseCase = MockSetLocaleUseCase();

      container = ProviderContainer(
        overrides: [
          getLocaleUseCaseProvider.overrideWithValue(mockGetLocaleUseCase),
          setLocaleUseCaseProvider.overrideWithValue(mockSetLocaleUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      '[P1] UNIT-LN-001: should return null when no locale is saved (system locale)',
      () async {
        // Arrange
        when(
          () => mockGetLocaleUseCase.call(any()),
        ).thenAnswer((_) async => Failure(const GetLocaleFailure.notFound()));

        // Act - le build() s'exécute automatiquement et retourne AsyncValue
        final result = await container.read(localeProvider.future);

        // Assert
        expect(result, isNull);
        verify(() => mockGetLocaleUseCase.call(any())).called(1);
      },
    );

    test(
      '[P1] UNIT-LN-002: should return saved locale when available',
      () async {
        // Arrange
        when(
          () => mockGetLocaleUseCase.call(any()),
        ).thenAnswer((_) async => Success(AppLocale.fr));

        // Act
        final result = await container.read(localeProvider.future);

        // Assert
        expect(result, const Locale('fr'));
        verify(() => mockGetLocaleUseCase.call(any())).called(1);
      },
    );

    test('[P1] UNIT-LN-003: should save locale with setLocale', () async {
      // Arrange
      when(
        () => mockGetLocaleUseCase.call(any()),
      ).thenAnswer((_) async => Failure(const GetLocaleFailure.notFound()));
      when(
        () => mockSetLocaleUseCase.call(any()),
      ).thenAnswer((_) async => const Success(unit));

      // Act
      await container.read(localeProvider.future);
      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('fr'));
      final result = await container.read(localeProvider.future);

      // Assert
      verify(() => mockSetLocaleUseCase.call(AppLocale.fr)).called(1);
      expect(result, const Locale('fr'));
    });

    test('[P1] UNIT-LN-004: should toggle from null to French', () async {
      // Arrange
      when(
        () => mockGetLocaleUseCase.call(const NoParams()),
      ).thenAnswer((_) async => Failure(const GetLocaleFailure.notFound()));
      when(
        () => mockSetLocaleUseCase.call(any()),
      ).thenAnswer((_) async => const Success(unit));

      // Act
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).toggleLocale();
      final toggledValue = await container.read(localeProvider.future);

      // Assert
      verify(() => mockSetLocaleUseCase.call(AppLocale.fr)).called(1);
      expect(toggledValue, const Locale('fr'));
    });

    test('[P1] UNIT-LN-005: should toggle from English to French', () async {
      // Arrange
      when(
        () => mockGetLocaleUseCase.call(any()),
      ).thenAnswer((_) async => Success(AppLocale.en));
      when(
        () => mockSetLocaleUseCase.call(any()),
      ).thenAnswer((_) async => Success(unit));

      // Act
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).toggleLocale();
      final toggledValue = await container.read(localeProvider.future);

      // Assert
      verify(() => mockSetLocaleUseCase.call(AppLocale.fr)).called(1);
      expect(toggledValue, const Locale('fr'));
    });

    test('[P1] UNIT-LN-006: should toggle from French to English', () async {
      // Arrange
      when(
        () => mockGetLocaleUseCase.call(any()),
      ).thenAnswer((_) async => Success(AppLocale.fr));
      when(
        () => mockSetLocaleUseCase.call(any()),
      ).thenAnswer((_) async => const Success(unit));

      // Act
      await container.read(localeProvider.future);
      await container.read(localeProvider.notifier).toggleLocale();
      final toggledValue = await container.read(localeProvider.future);

      // Assert
      verify(() => mockSetLocaleUseCase.call(AppLocale.en)).called(1);
      expect(toggledValue, const Locale('en'));
    });
  });

  group('supportedLocales - UNIT-SL', () {
    test('[P2] UNIT-SL-001: should contain English and French', () {
      // Arrange & Act & Assert
      expect(supportedLocales, contains(const Locale('en')));
      expect(supportedLocales, contains(const Locale('fr')));
    });

    test('[P2] UNIT-SL-002: should have exactly 2 locales', () {
      // Arrange & Act & Assert
      expect(supportedLocales.length, 2);
    });
  });
}

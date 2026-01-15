import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/settings/application/use_cases/set_locale_use_case.dart';
import 'package:tictactoe/features/settings/domain/repositories/i_locale_repository.dart';
import 'package:tictactoe/features/settings/domain/entities/app_locale.dart';
import 'package:tictactoe/features/settings/domain/failures/locale_repository_failures.dart';

// === MOCKS ===
class MockLocaleRepository extends Mock implements ILocaleRepository {}

void main() {
  // === SETUP ===
  late SetLocaleUseCase saveLocale;
  late MockLocaleRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AppLocale.en);
  });

  setUp(() {
    mockRepository = MockLocaleRepository();
    saveLocale = SetLocaleUseCase(mockRepository);
  });

  // === TESTS ===
  group('SetLocaleUseCase - UNIT-SLUC', () {
    group('call', () {
      test(
        '[P0] UNIT-SLUC-001: should save English locale via repository',
        () async {
          // Arrange
          const locale = AppLocale.en;
          when(
            () => mockRepository.setLocale(any()),
          ).thenAnswer((_) async => const Success(unit));

          // Act
          final result = await saveLocale(locale);

          // Assert
          result.fold((success) {
            expect(success, unit);
          }, (failure) => fail('Expected success but got failure: $failure'));
          verify(() => mockRepository.setLocale(locale)).called(1);
        },
      );

      test(
        '[P0] UNIT-SLUC-002: should save French locale via repository',
        () async {
          // Arrange
          const locale = AppLocale.fr;
          when(
            () => mockRepository.setLocale(any()),
          ).thenAnswer((_) async => const Success(unit));

          // Act
          final result = await saveLocale(locale);

          // Assert
          result.fold((success) {
            expect(success, unit);
          }, (failure) => fail('Expected success but got failure: $failure'));
          verify(() => mockRepository.setLocale(locale)).called(1);
        },
      );

      test(
        '[P0] UNIT-SLUC-003: should save custom locale via repository',
        () async {
          // Arrange
          const locale = AppLocale(languageCode: 'de');
          when(
            () => mockRepository.setLocale(any()),
          ).thenAnswer((_) async => const Success(unit));

          // Act
          final result = await saveLocale(locale);

          // Assert
          result.fold((success) {
            expect(success, unit);
          }, (failure) => fail('Expected success but got failure: $failure'));
          final captured =
              verify(() => mockRepository.setLocale(captureAny())).captured;
          expect(captured.first, locale);
        },
      );

      test('[P0] UNIT-SLUC-004: should call repository only once', () async {
        // Arrange
        const locale = AppLocale.en;
        when(
          () => mockRepository.setLocale(any()),
        ).thenAnswer((_) async => const Success(unit));

        // Act
        final result = await saveLocale(locale);

        // Assert
        result.fold((success) {
          expect(success, unit);
        }, (failure) => fail('Expected success but got failure: $failure'));
        verify(() => mockRepository.setLocale(any())).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test(
        '[P1] UNIT-SLUC-005: should return failure when repository returns failure',
        () async {
          // Arrange
          const locale = AppLocale.en;
          const failure = SetLocaleFailure.saveFailed();
          when(
            () => mockRepository.setLocale(any()),
          ).thenAnswer((_) async => Failure(failure));

          // Act
          final result = await saveLocale(locale);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (error) {
              expect(error, isA<SetLocaleFailure>());
              expect(error, failure);
            },
          );
          verify(() => mockRepository.setLocale(locale)).called(1);
        },
      );

      test(
        '[P1] UNIT-SLUC-006: should return failure when repository throws exception',
        () async {
          // Arrange
          const locale = AppLocale.en;
          when(
            () => mockRepository.setLocale(any()),
          ).thenThrow(Exception('Repository error'));

          // Act
          final result = await saveLocale(locale);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (error) {
              expect(error, isA<SetLocaleFailure>());
              expect(error, const SetLocaleFailure.saveFailed());
            },
          );
          verify(() => mockRepository.setLocale(locale)).called(1);
        },
      );
    });
  });
}

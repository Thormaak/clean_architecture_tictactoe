import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/core/application/usecases/use_case.dart';
import 'package:tictactoe/features/settings/application/use_cases/get_locale_use_case.dart';
import 'package:tictactoe/features/settings/domain/repositories/i_locale_repository.dart';
import 'package:tictactoe/features/settings/domain/entities/app_locale.dart';
import 'package:tictactoe/features/settings/domain/failures/locale_repository_failures.dart';

// === MOCKS ===
class MockLocaleRepository extends Mock implements ILocaleRepository {}

void main() {
  // === SETUP ===
  late GetLocaleUseCase sut;
  late MockLocaleRepository mockRepository;

  setUp(() {
    mockRepository = MockLocaleRepository();
    sut = GetLocaleUseCase(mockRepository);
  });

  // === TESTS ===
  group('GetLocaleUseCase', () {
    group('call', () {
      test('should return saved locale when one exists', () async {
        // Arrange
        const savedLocale = AppLocale.en;
        when(
          () => mockRepository.getLocale(),
        ).thenAnswer((_) async => Success(savedLocale));

        // Act
        final result = await sut(NoParams());

        // Assert
        result.fold((success) {
          expect(success, savedLocale);
        }, (failure) => fail('Expected success but got failure: $failure'));
        verify(() => mockRepository.getLocale()).called(1);
      });

      test(
        '[P1] UNIT-GLUC-002: should return notFound failure when no locale is saved',
        () async {
          // Arrange
          when(
            () => mockRepository.getLocale(),
          ).thenAnswer((_) async => Failure(const GetLocaleFailure.notFound()));

          // Act
          final result = await sut(NoParams());

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<GetLocaleNotFound>());
            },
          );
          verify(() => mockRepository.getLocale()).called(1);
        },
      );

      test(
        '[P1] UNIT-GLUC-003: should return French locale when fr is saved',
        () async {
          // Arrange
          const savedLocale = AppLocale.fr;
          when(
            () => mockRepository.getLocale(),
          ).thenAnswer((_) async => Success(savedLocale));

          // Act
          final result = await sut(NoParams());

          // Assert
          final locale = result.getOrElse(
            (failure) =>
                throw fail('Expected success but got failure: $failure'),
          );
          expect(locale, savedLocale);
          expect(locale.languageCode, 'fr');
        },
      );

      test(
        '[P1] UNIT-GLUC-004: should return repositoryError failure when exception is thrown',
        () async {
          // Arrange
          when(
            () => mockRepository.getLocale(),
          ).thenThrow(Exception('Repository error'));

          // Act
          final result = await sut(NoParams());

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<GetLocaleRepositoryError>());
            },
          );
          verify(() => mockRepository.getLocale()).called(1);
        },
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/features/settings/domain/entities/app_locale.dart';
import 'package:tictactoe/features/settings/domain/failures/locale_repository_failures.dart';
import 'package:tictactoe/features/settings/infrastructure/repositories/locale_repository_impl.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late LocaleRepositoryImpl sut;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    sut = LocaleRepositoryImpl(mockPrefs);
  });

  group('LocaleRepositoryImpl', () {
    group('getLocale', () {
      test('should return Success with AppLocale when locale exists', () async {
        // Arrange
        when(() => mockPrefs.getString('app_locale')).thenReturn('en');

        // Act
        final result = await sut.getLocale();

        // Assert
        expect(result.isSuccess(), true);
        result.fold(
          (locale) => expect(locale.languageCode, 'en'),
          (failure) => fail('Should not be a failure'),
        );
        verify(() => mockPrefs.getString('app_locale')).called(1);
      });

      test('should return Failure.notFound when locale does not exist',
          () async {
        // Arrange
        when(() => mockPrefs.getString('app_locale')).thenReturn(null);

        // Act
        final result = await sut.getLocale();

        // Assert
        expect(result.isError(), true);
        result.fold(
          (locale) => fail('Should not be a success'),
          (failure) => expect(failure, const GetLocaleFailure.notFound()),
        );
      });
    });

    group('setLocale', () {
      test('should return Success when locale is saved successfully', () async {
        // Arrange
        const locale = AppLocale(languageCode: 'fr');
        when(() => mockPrefs.setString('app_locale', 'fr'))
            .thenAnswer((_) async => true);

        // Act
        final result = await sut.setLocale(locale);

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockPrefs.setString('app_locale', 'fr')).called(1);
      });

      test('should return Failure.saveFailed when save returns false',
          () async {
        // Arrange
        const locale = AppLocale(languageCode: 'fr');
        when(() => mockPrefs.setString('app_locale', 'fr'))
            .thenAnswer((_) async => false);

        // Act
        final result = await sut.setLocale(locale);

        // Assert
        expect(result.isError(), true);
        result.fold(
          (success) => fail('Should not be a success'),
          (failure) => expect(failure, const SetLocaleFailure.saveFailed()),
        );
      });

      test('should return Failure.unexpected when exception occurs', () async {
        // Arrange
        const locale = AppLocale(languageCode: 'fr');
        when(() => mockPrefs.setString('app_locale', 'fr'))
            .thenThrow(Exception('error'));

        // Act
        final result = await sut.setLocale(locale);

        // Assert
        expect(result.isError(), true);
        result.fold(
          (success) => fail('Should not be a success'),
          (failure) => expect(failure, const SetLocaleFailure.unexpected()),
        );
      });
    });

    group('clearLocale', () {
      test('should return Success when locale is cleared successfully',
          () async {
        // Arrange
        when(() => mockPrefs.remove('app_locale'))
            .thenAnswer((_) async => true);

        // Act
        final result = await sut.clearLocale();

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockPrefs.remove('app_locale')).called(1);
      });

      test('should return Failure.saveFailed when remove returns false',
          () async {
        // Arrange
        when(() => mockPrefs.remove('app_locale'))
            .thenAnswer((_) async => false);

        // Act
        final result = await sut.clearLocale();

        // Assert
        expect(result.isError(), true);
        result.fold(
          (success) => fail('Should not be a success'),
          (failure) => expect(failure, const SetLocaleFailure.saveFailed()),
        );
      });

      test('should return Failure.unexpected when exception occurs', () async {
        // Arrange
        when(() => mockPrefs.remove('app_locale'))
            .thenThrow(Exception('error'));

        // Act
        final result = await sut.clearLocale();

        // Assert
        expect(result.isError(), true);
        result.fold(
          (success) => fail('Should not be a success'),
          (failure) => expect(failure, const SetLocaleFailure.unexpected()),
        );
      });
    });
  });
}

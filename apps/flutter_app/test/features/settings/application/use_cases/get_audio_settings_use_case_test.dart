import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/core/application/usecases/use_case.dart';
import 'package:tictactoe/features/settings/application/use_cases/get_audio_settings_use_case.dart';
import 'package:tictactoe/features/settings/domain/entities/audio_settings.dart';
import 'package:tictactoe/features/settings/domain/failures/audio_settings_failures.dart';
import 'package:tictactoe/features/settings/domain/repositories/i_audio_settings_repository.dart';

class MockAudioSettingsRepository extends Mock
    implements IAudioSettingsRepository {}

void main() {
  late GetAudioSettingsUseCase sut;
  late MockAudioSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioSettingsRepository();
    sut = GetAudioSettingsUseCase(mockRepository);
  });

  group('GetAudioSettingsUseCase', () {
    group('call', () {
      test('should return Success with AudioSettings when repository succeeds',
          () async {
        // Arrange
        final settings = AudioSettings.defaults();
        when(() => mockRepository.getAudioSettings())
            .thenAnswer((_) async => Success(settings));

        // Act
        final result = await sut.call(const NoParams());

        // Assert
        expect(result.isSuccess(), true);
        result.fold(
          (value) {
            expect(value.musicVolume, AudioSettings.defaultMusicVolume);
            expect(value.sfxVolume, AudioSettings.defaultSfxVolume);
            expect(value.muted, false);
            expect(value.clickSoundEnabled, true);
          },
          (failure) => fail('Should not be a failure'),
        );
        verify(() => mockRepository.getAudioSettings()).called(1);
      });

      test('should return Success with custom AudioSettings', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.5,
          sfxVolume: 0.7,
          muted: true,
          clickSoundEnabled: false,
        );
        when(() => mockRepository.getAudioSettings())
            .thenAnswer((_) async => const Success(settings));

        // Act
        final result = await sut.call(const NoParams());

        // Assert
        expect(result.isSuccess(), true);
        result.fold(
          (value) {
            expect(value.musicVolume, 0.5);
            expect(value.sfxVolume, 0.7);
            expect(value.muted, true);
            expect(value.clickSoundEnabled, false);
          },
          (failure) => fail('Should not be a failure'),
        );
      });

      test('should return Failure.unexpected when repository throws exception',
          () async {
        // Arrange
        when(() => mockRepository.getAudioSettings())
            .thenThrow(Exception('error'));

        // Act
        final result = await sut.call(const NoParams());

        // Assert
        expect(result.isError(), true);
        result.fold(
          (value) => fail('Should not be a success'),
          (failure) => expect(failure, const GetAudioSettingsUnexpected()),
        );
      });

      test(
          'should return Failure.unexpected when repository returns unexpected error',
          () async {
        // Arrange
        when(() => mockRepository.getAudioSettings())
            .thenAnswer((_) async => throw StateError('unexpected'));

        // Act
        final result = await sut.call(const NoParams());

        // Assert
        expect(result.isError(), true);
        result.fold(
          (value) => fail('Should not be a success'),
          (failure) => expect(failure, const GetAudioSettingsUnexpected()),
        );
      });
    });
  });
}

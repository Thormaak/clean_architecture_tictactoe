import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/settings/application/use_cases/set_audio_settings_use_case.dart';
import 'package:tictactoe/features/settings/domain/entities/audio_settings.dart';
import 'package:tictactoe/features/settings/domain/failures/audio_settings_failures.dart';
import 'package:tictactoe/features/settings/domain/repositories/i_audio_settings_repository.dart';

class MockAudioSettingsRepository extends Mock
    implements IAudioSettingsRepository {}

void main() {
  late SetAudioSettingsUseCase sut;
  late MockAudioSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AudioSettings.defaults());
  });

  setUp(() {
    mockRepository = MockAudioSettingsRepository();
    sut = SetAudioSettingsUseCase(mockRepository);
  });

  group('SetAudioSettingsUseCase', () {
    group('call', () {
      test('should return Success when repository saves successfully',
          () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.5,
          sfxVolume: 0.7,
          muted: false,
          clickSoundEnabled: true,
        );
        when(() => mockRepository.setAudioSettings(settings))
            .thenAnswer((_) async => const Success(unit));

        // Act
        final result = await sut.call(settings);

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockRepository.setAudioSettings(settings)).called(1);
      });

      test('should return Success with default settings', () async {
        // Arrange
        final settings = AudioSettings.defaults();
        when(() => mockRepository.setAudioSettings(any()))
            .thenAnswer((_) async => const Success(unit));

        // Act
        final result = await sut.call(settings);

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockRepository.setAudioSettings(settings)).called(1);
      });

      test('should return Success with muted settings', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.35,
          sfxVolume: 0.8,
          muted: true,
          clickSoundEnabled: false,
        );
        when(() => mockRepository.setAudioSettings(settings))
            .thenAnswer((_) async => const Success(unit));

        // Act
        final result = await sut.call(settings);

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockRepository.setAudioSettings(settings)).called(1);
      });

      test('should return Failure.saveFailed when repository returns failure',
          () async {
        // Arrange
        final settings = AudioSettings.defaults();
        when(() => mockRepository.setAudioSettings(any()))
            .thenAnswer((_) async => const Failure(SetAudioSettingsSaveFailed()));

        // Act
        final result = await sut.call(settings);

        // Assert
        expect(result.isError(), true);
        result.fold(
          (value) => fail('Should not be a success'),
          (failure) => expect(failure, const SetAudioSettingsSaveFailed()),
        );
      });

      test('should return Failure.saveFailed when repository throws exception',
          () async {
        // Arrange
        final settings = AudioSettings.defaults();
        when(() => mockRepository.setAudioSettings(any()))
            .thenThrow(Exception('error'));

        // Act
        final result = await sut.call(settings);

        // Assert
        expect(result.isError(), true);
        result.fold(
          (value) => fail('Should not be a success'),
          (failure) => expect(failure, const SetAudioSettingsSaveFailed()),
        );
      });

      test(
          'should return Failure.saveFailed when repository returns unexpected error',
          () async {
        // Arrange
        final settings = AudioSettings.defaults();
        when(() => mockRepository.setAudioSettings(any()))
            .thenThrow(StateError('unexpected'));

        // Act
        final result = await sut.call(settings);

        // Assert
        expect(result.isError(), true);
        result.fold(
          (value) => fail('Should not be a success'),
          (failure) => expect(failure, const SetAudioSettingsSaveFailed()),
        );
      });

      test('should handle settings with extreme values', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.0,
          sfxVolume: 1.0,
          muted: false,
          clickSoundEnabled: true,
        );
        when(() => mockRepository.setAudioSettings(settings))
            .thenAnswer((_) async => const Success(unit));

        // Act
        final result = await sut.call(settings);

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockRepository.setAudioSettings(settings)).called(1);
      });
    });
  });
}

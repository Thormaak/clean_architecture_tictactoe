import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/features/settings/domain/entities/audio_settings.dart';
import 'package:tictactoe/features/settings/infrastructure/repositories/audio_settings_repository_impl.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AudioSettingsRepositoryImpl sut;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    sut = AudioSettingsRepositoryImpl(mockPrefs);
  });

  group('AudioSettingsRepositoryImpl', () {
    group('getAudioSettings', () {
      test('should return Success with default values when keys do not exist',
          () async {
        // Arrange
        when(() => mockPrefs.getDouble('audio_music_volume')).thenReturn(null);
        when(() => mockPrefs.getDouble('audio_sfx_volume')).thenReturn(null);
        when(() => mockPrefs.getBool('audio_muted')).thenReturn(null);
        when(() => mockPrefs.getBool('audio_click_sound_enabled'))
            .thenReturn(null);

        // Act
        final result = await sut.getAudioSettings();

        // Assert
        expect(result.isSuccess(), true);
        result.fold(
          (settings) {
            expect(settings.musicVolume, AudioSettings.defaultMusicVolume);
            expect(settings.sfxVolume, AudioSettings.defaultSfxVolume);
            expect(settings.muted, false);
            expect(settings.clickSoundEnabled, true);
          },
          (failure) => fail('Should not be a failure'),
        );
      });

      test('should return Success with stored values when keys exist',
          () async {
        // Arrange
        when(() => mockPrefs.getDouble('audio_music_volume')).thenReturn(0.8);
        when(() => mockPrefs.getDouble('audio_sfx_volume')).thenReturn(0.6);
        when(() => mockPrefs.getBool('audio_muted')).thenReturn(true);
        when(() => mockPrefs.getBool('audio_click_sound_enabled'))
            .thenReturn(false);

        // Act
        final result = await sut.getAudioSettings();

        // Assert
        expect(result.isSuccess(), true);
        result.fold(
          (settings) {
            expect(settings.musicVolume, 0.8);
            expect(settings.sfxVolume, 0.6);
            expect(settings.muted, true);
            expect(settings.clickSoundEnabled, false);
          },
          (failure) => fail('Should not be a failure'),
        );
      });

      test('should return sanitized values when stored values are out of range',
          () async {
        // Arrange
        when(() => mockPrefs.getDouble('audio_music_volume')).thenReturn(1.5);
        when(() => mockPrefs.getDouble('audio_sfx_volume')).thenReturn(-0.5);
        when(() => mockPrefs.getBool('audio_muted')).thenReturn(false);
        when(() => mockPrefs.getBool('audio_click_sound_enabled'))
            .thenReturn(true);

        // Act
        final result = await sut.getAudioSettings();

        // Assert
        expect(result.isSuccess(), true);
        result.fold(
          (settings) {
            expect(settings.musicVolume, 1.0);
            expect(settings.sfxVolume, 0.0);
          },
          (failure) => fail('Should not be a failure'),
        );
      });

      test('should return Failure.unexpected when exception occurs', () async {
        // Arrange
        when(() => mockPrefs.getDouble('audio_music_volume'))
            .thenThrow(Exception('error'));

        // Act
        final result = await sut.getAudioSettings();

        // Assert
        expect(result.isError(), true);
      });
    });

    group('setAudioSettings', () {
      test('should return Success when all keys are saved successfully',
          () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.7,
          sfxVolume: 0.5,
          muted: true,
          clickSoundEnabled: false,
        );
        when(() => mockPrefs.setDouble('audio_music_volume', 0.7))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setDouble('audio_sfx_volume', 0.5))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setBool('audio_muted', true))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setBool('audio_click_sound_enabled', false))
            .thenAnswer((_) async => true);

        // Act
        final result = await sut.setAudioSettings(settings);

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockPrefs.setDouble('audio_music_volume', 0.7)).called(1);
        verify(() => mockPrefs.setDouble('audio_sfx_volume', 0.5)).called(1);
        verify(() => mockPrefs.setBool('audio_muted', true)).called(1);
        verify(() => mockPrefs.setBool('audio_click_sound_enabled', false))
            .called(1);
      });

      test('should sanitize values before saving', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 1.5,
          sfxVolume: -0.5,
          muted: false,
          clickSoundEnabled: true,
        );
        when(() => mockPrefs.setDouble('audio_music_volume', 1.0))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setDouble('audio_sfx_volume', 0.0))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setBool('audio_muted', false))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setBool('audio_click_sound_enabled', true))
            .thenAnswer((_) async => true);

        // Act
        final result = await sut.setAudioSettings(settings);

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockPrefs.setDouble('audio_music_volume', 1.0)).called(1);
        verify(() => mockPrefs.setDouble('audio_sfx_volume', 0.0)).called(1);
      });

      test('should return Failure.saveFailed when any save returns false',
          () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.7,
          sfxVolume: 0.5,
          muted: true,
          clickSoundEnabled: false,
        );
        when(() => mockPrefs.setDouble('audio_music_volume', 0.7))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setDouble('audio_sfx_volume', 0.5))
            .thenAnswer((_) async => false);
        when(() => mockPrefs.setBool('audio_muted', true))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setBool('audio_click_sound_enabled', false))
            .thenAnswer((_) async => true);

        // Act
        final result = await sut.setAudioSettings(settings);

        // Assert
        expect(result.isError(), true);
      });

      test('should return Failure.unexpected when exception occurs', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.7,
          sfxVolume: 0.5,
          muted: true,
          clickSoundEnabled: false,
        );
        when(() => mockPrefs.setDouble('audio_music_volume', 0.7))
            .thenThrow(Exception('error'));

        // Act
        final result = await sut.setAudioSettings(settings);

        // Assert
        expect(result.isError(), true);
      });
    });
  });
}

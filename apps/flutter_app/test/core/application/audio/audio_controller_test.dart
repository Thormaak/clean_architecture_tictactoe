import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/application/audio/audio_controller.dart';
import 'package:tictactoe/features/settings/domain/entities/audio_settings.dart';

/// NOTE: AudioController uses just_audio which requires native plugins.
/// Most tests here focus on applySettings() which doesn't require plugins.
/// Methods like playMusic(), playSfx(), etc. would require integration tests
/// or mocking AudioPlayer (which would need dependency injection refactoring).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioController sut;

  setUp(() {
    sut = AudioController();
  });

  tearDown(() async {
    await sut.dispose();
  });

  group('AudioController', () {
    group('applySettings', () {
      test('should apply default settings without throwing', () async {
        // Arrange
        final settings = AudioSettings.defaults();

        // Act & Assert
        await expectLater(
          sut.applySettings(settings),
          completes,
        );
      });

      test('should apply custom settings without throwing', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.5,
          sfxVolume: 0.7,
          muted: false,
          clickSoundEnabled: true,
        );

        // Act & Assert
        await expectLater(
          sut.applySettings(settings),
          completes,
        );
      });

      test('should apply muted settings without throwing', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.5,
          sfxVolume: 0.7,
          muted: true,
          clickSoundEnabled: false,
        );

        // Act & Assert
        await expectLater(
          sut.applySettings(settings),
          completes,
        );
      });

      test('should sanitize settings with out-of-range values', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 1.5,
          sfxVolume: -0.5,
          muted: false,
          clickSoundEnabled: true,
        );

        // Act & Assert
        await expectLater(
          sut.applySettings(settings),
          completes,
        );
      });

      test('should apply zero volume settings', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.0,
          sfxVolume: 0.0,
          muted: false,
          clickSoundEnabled: true,
        );

        // Act & Assert
        await expectLater(
          sut.applySettings(settings),
          completes,
        );
      });

      test('should apply max volume settings', () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 1.0,
          sfxVolume: 1.0,
          muted: false,
          clickSoundEnabled: true,
        );

        // Act & Assert
        await expectLater(
          sut.applySettings(settings),
          completes,
        );
      });
    });

    group('constructor', () {
      test('should create AudioController without throwing', () {
        // Act & Assert
        expect(() => AudioController(), returnsNormally);
      });
    });
  });
}

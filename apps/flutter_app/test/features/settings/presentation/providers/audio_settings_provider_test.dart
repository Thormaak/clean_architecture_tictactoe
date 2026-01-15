import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/core/application/usecases/use_case.dart';
import 'package:tictactoe/features/settings/application/use_cases/get_audio_settings_use_case.dart';
import 'package:tictactoe/features/settings/application/use_cases/set_audio_settings_use_case.dart';
import 'package:tictactoe/features/settings/domain/entities/audio_settings.dart';
import 'package:tictactoe/features/settings/domain/failures/audio_settings_failures.dart';
import 'package:tictactoe/features/settings/presentation/providers/audio_settings_provider.dart';
import 'package:tictactoe/features/settings/presentation/providers/audio_settings_providers.dart';

class MockGetAudioSettingsUseCase extends Mock
    implements GetAudioSettingsUseCase {}

class MockSetAudioSettingsUseCase extends Mock
    implements SetAudioSettingsUseCase {}

void main() {
  late MockGetAudioSettingsUseCase mockGetUseCase;
  late MockSetAudioSettingsUseCase mockSetUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(AudioSettings.defaults());
  });

  setUp(() {
    mockGetUseCase = MockGetAudioSettingsUseCase();
    mockSetUseCase = MockSetAudioSettingsUseCase();

    container = ProviderContainer(
      overrides: [
        getAudioSettingsUseCaseProvider.overrideWithValue(mockGetUseCase),
        setAudioSettingsUseCaseProvider.overrideWithValue(mockSetUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AudioSettingsNotifier', () {
    group('build', () {
      test('should load settings from GetAudioSettingsUseCase on init',
          () async {
        // Arrange
        final settings = AudioSettings.defaults();
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Success(settings));

        // Act
        final result = await container.read(audioSettingsProvider.future);

        // Assert
        expect(result.musicVolume, AudioSettings.defaultMusicVolume);
        expect(result.sfxVolume, AudioSettings.defaultSfxVolume);
        expect(result.muted, false);
        expect(result.clickSoundEnabled, true);
        verify(() => mockGetUseCase.call(const NoParams())).called(1);
      });

      test('should return defaults when GetAudioSettingsUseCase fails',
          () async {
        // Arrange
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => const Failure(GetAudioSettingsUnexpected()));

        // Act
        final result = await container.read(audioSettingsProvider.future);

        // Assert
        expect(result, AudioSettings.defaults());
      });

      test('should load custom settings from GetAudioSettingsUseCase',
          () async {
        // Arrange
        const settings = AudioSettings(
          musicVolume: 0.6,
          sfxVolume: 0.9,
          muted: true,
          clickSoundEnabled: false,
        );
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => const Success(settings));

        // Act
        final result = await container.read(audioSettingsProvider.future);

        // Assert
        expect(result.musicVolume, 0.6);
        expect(result.sfxVolume, 0.9);
        expect(result.muted, true);
        expect(result.clickSoundEnabled, false);
      });
    });

    group('setMusicVolume', () {
      test('should update music volume and save', () async {
        // Arrange
        final initialSettings = AudioSettings.defaults();
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Success(initialSettings));
        when(() => mockSetUseCase.call(any()))
            .thenAnswer((_) async => const Success(unit));

        await container.read(audioSettingsProvider.future);

        // Act
        await container
            .read(audioSettingsProvider.notifier)
            .setMusicVolume(0.7);

        // Assert
        final result = container.read(audioSettingsProvider).value!;
        expect(result.musicVolume, 0.7);
        verify(() => mockSetUseCase.call(any())).called(1);
      });

      test('should rollback on save failure', () async {
        // Arrange
        final initialSettings = AudioSettings.defaults();
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Success(initialSettings));
        when(() => mockSetUseCase.call(any())).thenAnswer(
          (_) async => const Failure(SetAudioSettingsSaveFailed()),
        );

        await container.read(audioSettingsProvider.future);

        // Act
        await container
            .read(audioSettingsProvider.notifier)
            .setMusicVolume(0.7);

        // Assert
        final result = container.read(audioSettingsProvider).value!;
        expect(result.musicVolume, AudioSettings.defaultMusicVolume);
      });
    });

    group('setSfxVolume', () {
      test('should update sfx volume and save', () async {
        // Arrange
        final initialSettings = AudioSettings.defaults();
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Success(initialSettings));
        when(() => mockSetUseCase.call(any()))
            .thenAnswer((_) async => const Success(unit));

        await container.read(audioSettingsProvider.future);

        // Act
        await container.read(audioSettingsProvider.notifier).setSfxVolume(0.5);

        // Assert
        final result = container.read(audioSettingsProvider).value!;
        expect(result.sfxVolume, 0.5);
        verify(() => mockSetUseCase.call(any())).called(1);
      });

      test('should rollback on save failure', () async {
        // Arrange
        final initialSettings = AudioSettings.defaults();
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Success(initialSettings));
        when(() => mockSetUseCase.call(any())).thenAnswer(
          (_) async => const Failure(SetAudioSettingsSaveFailed()),
        );

        await container.read(audioSettingsProvider.future);

        // Act
        await container.read(audioSettingsProvider.notifier).setSfxVolume(0.5);

        // Assert
        final result = container.read(audioSettingsProvider).value!;
        expect(result.sfxVolume, AudioSettings.defaultSfxVolume);
      });
    });

    group('setMuted', () {
      test('should update muted state and save', () async {
        // Arrange
        final initialSettings = AudioSettings.defaults();
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Success(initialSettings));
        when(() => mockSetUseCase.call(any()))
            .thenAnswer((_) async => const Success(unit));

        await container.read(audioSettingsProvider.future);

        // Act
        await container.read(audioSettingsProvider.notifier).setMuted(true);

        // Assert
        final result = container.read(audioSettingsProvider).value!;
        expect(result.muted, true);
        verify(() => mockSetUseCase.call(any())).called(1);
      });
    });

    group('setClickSoundEnabled', () {
      test('should update click sound state and save', () async {
        // Arrange
        final initialSettings = AudioSettings.defaults();
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Success(initialSettings));
        when(() => mockSetUseCase.call(any()))
            .thenAnswer((_) async => const Success(unit));

        await container.read(audioSettingsProvider.future);

        // Act
        await container
            .read(audioSettingsProvider.notifier)
            .setClickSoundEnabled(false);

        // Assert
        final result = container.read(audioSettingsProvider).value!;
        expect(result.clickSoundEnabled, false);
        verify(() => mockSetUseCase.call(any())).called(1);
      });
    });

    group('toggleMute', () {
      test('should toggle muted from false to true', () async {
        // Arrange
        final initialSettings = AudioSettings.defaults();
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Success(initialSettings));
        when(() => mockSetUseCase.call(any()))
            .thenAnswer((_) async => const Success(unit));

        await container.read(audioSettingsProvider.future);

        // Act
        await container.read(audioSettingsProvider.notifier).toggleMute();

        // Assert
        final result = container.read(audioSettingsProvider).value!;
        expect(result.muted, true);
      });

      test('should toggle muted from true to false', () async {
        // Arrange
        const initialSettings = AudioSettings(
          musicVolume: 0.35,
          sfxVolume: 0.8,
          muted: true,
          clickSoundEnabled: true,
        );
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => const Success(initialSettings));
        when(() => mockSetUseCase.call(any()))
            .thenAnswer((_) async => const Success(unit));

        await container.read(audioSettingsProvider.future);

        // Act
        await container.read(audioSettingsProvider.notifier).toggleMute();

        // Assert
        final result = container.read(audioSettingsProvider).value!;
        expect(result.muted, false);
      });
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/entities/audio_settings.dart';
import 'audio_settings_providers.dart';

class AudioSettingsNotifier extends AsyncNotifier<AudioSettings> {
  @override
  Future<AudioSettings> build() async {
    final getUseCase = ref.read(getAudioSettingsUseCaseProvider);
    final result = await getUseCase.call(const NoParams());
    return result.fold((settings) => settings, (_) => AudioSettings.defaults());
  }

  Future<void> setMusicVolume(double value) async {
    final current = state.value ?? await future;
    await _save(current.copyWith(musicVolume: value));
  }

  Future<void> setSfxVolume(double value) async {
    final current = state.value ?? await future;
    await _save(current.copyWith(sfxVolume: value));
  }

  Future<void> setMuted(bool muted) async {
    final current = state.value ?? await future;
    await _save(current.copyWith(muted: muted));
  }

  Future<void> setClickSoundEnabled(bool enabled) async {
    final current = state.value ?? await future;
    await _save(current.copyWith(clickSoundEnabled: enabled));
  }

  Future<void> toggleMute() async {
    final current = state.value ?? await future;
    await _save(current.copyWith(muted: !current.muted));
  }

  Future<void> _save(AudioSettings updated) async {
    final previous = state.value ?? await future;
    state = AsyncValue.data(updated);

    final result = await ref
        .read(setAudioSettingsUseCaseProvider)
        .call(updated);
    result.fold((_) {}, (_) {
      state = AsyncValue.data(previous);
    });
  }
}

final audioSettingsProvider =
    AsyncNotifierProvider<AudioSettingsNotifier, AudioSettings>(
      AudioSettingsNotifier.new,
    );

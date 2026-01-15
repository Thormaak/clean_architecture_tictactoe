import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../features/settings/domain/entities/audio_settings.dart';
import '../../../features/settings/presentation/providers/audio_settings_provider.dart';

enum MusicTrack { menu }

enum SfxType { place, invalid, gameOver, click }

class AudioController {
  AudioController() {
    _musicPlayer.setLoopMode(LoopMode.one);
  }

  static const _menuMusic = 'assets/audio/KarolPiczak-LesChampsEtoiles.mp3';
  static const _sfxPlace = 'assets/audio/sfx_click.wav';
  static const _sfxInvalid = 'assets/audio/sfx_deny.wav';
  static const _sfxGameOver = 'assets/audio/sfx_game_over.wav';
  static const _sfxClick = 'assets/audio/sfx_click.wav';

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  MusicTrack? _currentTrack;
  AudioSettings _settings = AudioSettings.defaults();

  Future<void> applySettings(AudioSettings settings) async {
    _settings = settings.sanitized();
    try {
      await _musicPlayer.setVolume(_settings.effectiveMusicVolume);
      await _sfxPlayer.setVolume(_settings.effectiveSfxVolume);
    } catch (error, stackTrace) {
      debugPrint(
        'AudioController: impossible d\'appliquer les reglages audio: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> playMusic(MusicTrack track) async {
    if (_currentTrack == track && _musicPlayer.playing) {
      return;
    }

    _currentTrack = track;
    final asset = _menuMusic;

    try {
      await _musicPlayer.setVolume(_settings.effectiveMusicVolume);
      await _musicPlayer.setAsset(asset);
      await _musicPlayer.play();
    } catch (error, stackTrace) {
      debugPrint('AudioController: impossible de lire la musique: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (error, stackTrace) {
      debugPrint('AudioController: impossible d\'arreter la musique: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> playSfx(SfxType type) async {
    if (_settings.effectiveSfxVolume <= 0) {
      return;
    }
    if (type == SfxType.click && !_settings.clickSoundEnabled) {
      return;
    }

    final asset = switch (type) {
      SfxType.place => _sfxPlace,
      SfxType.invalid => _sfxInvalid,
      SfxType.gameOver => _sfxGameOver,
      SfxType.click => _sfxClick,
    };

    try {
      await _sfxPlayer.setVolume(_settings.effectiveSfxVolume);
      await _sfxPlayer.setAsset(asset);
      await _sfxPlayer.play();
    } catch (error, stackTrace) {
      debugPrint('AudioController: impossible de lire le SFX: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

final audioControllerProvider = Provider<AudioController>((ref) {
  final controller = AudioController();
  ref.onDispose(controller.dispose);

  ref.listen<AsyncValue<AudioSettings>>(audioSettingsProvider, (
    previous,
    next,
  ) {
    final settings = next.asData?.value;
    if (settings != null) {
      controller.applySettings(settings);
    }
  });

  final settings = ref.read(audioSettingsProvider).asData?.value;
  if (settings != null) {
    controller.applySettings(settings);
  }

  return controller;
});

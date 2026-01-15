import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/audio_settings.dart';
import '../../domain/failures/audio_settings_failures.dart';
import '../../domain/repositories/i_audio_settings_repository.dart';

/// Implementation of AudioSettings repository using SharedPreferences
class AudioSettingsRepositoryImpl implements IAudioSettingsRepository {
  static const _musicVolumeKey = 'audio_music_volume';
  static const _sfxVolumeKey = 'audio_sfx_volume';
  static const _mutedKey = 'audio_muted';
  static const _clickSoundEnabledKey = 'audio_click_sound_enabled';

  final SharedPreferences _prefs;

  AudioSettingsRepositoryImpl(this._prefs);

  @override
  AsyncResultDart<AudioSettings, GetAudioSettingsFailure>
  getAudioSettings() async {
    try {
      final musicVolume =
          _prefs.getDouble(_musicVolumeKey) ?? AudioSettings.defaultMusicVolume;
      final sfxVolume =
          _prefs.getDouble(_sfxVolumeKey) ?? AudioSettings.defaultSfxVolume;
      final muted = _prefs.getBool(_mutedKey) ?? false;
      final clickSoundEnabled = _prefs.getBool(_clickSoundEnabledKey) ?? true;

      return Success(
        AudioSettings(
          musicVolume: musicVolume,
          sfxVolume: sfxVolume,
          muted: muted,
          clickSoundEnabled: clickSoundEnabled,
        ).sanitized(),
      );
    } catch (_) {
      return Failure(const GetAudioSettingsUnexpected());
    }
  }

  @override
  AsyncResultDart<Unit, SetAudioSettingsFailure> setAudioSettings(
    AudioSettings settings,
  ) async {
    try {
      final sanitized = settings.sanitized();
      final musicOk = await _prefs.setDouble(
        _musicVolumeKey,
        sanitized.musicVolume,
      );
      final sfxOk = await _prefs.setDouble(_sfxVolumeKey, sanitized.sfxVolume);
      final mutedOk = await _prefs.setBool(_mutedKey, sanitized.muted);
      final clickOk = await _prefs.setBool(
        _clickSoundEnabledKey,
        sanitized.clickSoundEnabled,
      );

      if (musicOk && sfxOk && mutedOk && clickOk) {
        return Success(unit);
      }
      return Failure(const SetAudioSettingsSaveFailed());
    } catch (_) {
      return Failure(const SetAudioSettingsUnexpected());
    }
  }
}

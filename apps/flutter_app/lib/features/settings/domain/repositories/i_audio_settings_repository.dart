import 'package:result_dart/result_dart.dart';

import '../entities/audio_settings.dart';
import '../failures/audio_settings_failures.dart';

/// Repository interface for managing audio settings preferences
abstract class IAudioSettingsRepository {
  /// Get the stored audio settings or defaults if none is saved
  AsyncResultDart<AudioSettings, GetAudioSettingsFailure> getAudioSettings();

  /// Save audio settings
  AsyncResultDart<Unit, SetAudioSettingsFailure> setAudioSettings(
    AudioSettings settings,
  );
}

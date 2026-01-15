sealed class GetAudioSettingsFailure implements Exception {
  const GetAudioSettingsFailure();
}

class GetAudioSettingsUnexpected extends GetAudioSettingsFailure {
  const GetAudioSettingsUnexpected();
}

sealed class SetAudioSettingsFailure implements Exception {
  const SetAudioSettingsFailure();
}

class SetAudioSettingsSaveFailed extends SetAudioSettingsFailure {
  const SetAudioSettingsSaveFailed();
}

class SetAudioSettingsUnexpected extends SetAudioSettingsFailure {
  const SetAudioSettingsUnexpected();
}

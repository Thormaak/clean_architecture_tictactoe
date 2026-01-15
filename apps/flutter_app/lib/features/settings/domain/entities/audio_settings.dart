class AudioSettings {
  static const double defaultMusicVolume = 0.35;
  static const double defaultSfxVolume = 0.8;

  final double musicVolume;
  final double sfxVolume;
  final bool muted;
  final bool clickSoundEnabled;

  const AudioSettings({
    required this.musicVolume,
    required this.sfxVolume,
    required this.muted,
    required this.clickSoundEnabled,
  });

  factory AudioSettings.defaults() {
    return const AudioSettings(
      musicVolume: defaultMusicVolume,
      sfxVolume: defaultSfxVolume,
      muted: false,
      clickSoundEnabled: true,
    );
  }

  AudioSettings copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? muted,
    bool? clickSoundEnabled,
  }) {
    return AudioSettings(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      muted: muted ?? this.muted,
      clickSoundEnabled: clickSoundEnabled ?? this.clickSoundEnabled,
    );
  }

  AudioSettings sanitized() {
    return AudioSettings(
      musicVolume: _clamp(musicVolume),
      sfxVolume: _clamp(sfxVolume),
      muted: muted,
      clickSoundEnabled: clickSoundEnabled,
    );
  }

  double get effectiveMusicVolume => muted ? 0.0 : musicVolume;
  double get effectiveSfxVolume => muted ? 0.0 : sfxVolume;

  static double _clamp(double value) {
    final clamped = value.clamp(0.0, 1.0);
    return clamped.toDouble();
  }
}

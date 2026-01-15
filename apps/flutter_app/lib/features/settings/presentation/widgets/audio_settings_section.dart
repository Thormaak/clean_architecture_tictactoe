import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../core/presentation/theme/gaming_theme.dart';
import '../providers/audio_settings_provider.dart';

class AudioSettingsSection extends ConsumerWidget {
  const AudioSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(audioSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.audioSettings,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.audioMute,
                style: const TextStyle(color: Colors.white),
              ),
              value: settings.muted,
              activeThumbColor: GamingTheme.accentPink,
              onChanged:
                  (value) =>
                      ref.read(audioSettingsProvider.notifier).setMuted(value),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.audioClickSound,
                style: const TextStyle(color: Colors.white),
              ),
              value: settings.clickSoundEnabled,
              activeThumbColor: GamingTheme.accentPink,
              onChanged:
                  (value) => ref
                      .read(audioSettingsProvider.notifier)
                      .setClickSoundEnabled(value),
            ),
            const SizedBox(height: 8),
            _VolumeSlider(
              label: l10n.audioMusicVolume,
              value: settings.musicVolume,
              onChanged:
                  (value) => ref
                      .read(audioSettingsProvider.notifier)
                      .setMusicVolume(value),
            ),
            const SizedBox(height: 8),
            _VolumeSlider(
              label: l10n.audioSfxVolume,
              value: settings.sfxVolume,
              onChanged:
                  (value) => ref
                      .read(audioSettingsProvider.notifier)
                      .setSfxVolume(value),
            ),
          ],
        );
      },
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: GamingTheme.accentCyan),
          ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          activeColor: GamingTheme.accentPurple,
          inactiveColor: GamingTheme.accentPurple.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

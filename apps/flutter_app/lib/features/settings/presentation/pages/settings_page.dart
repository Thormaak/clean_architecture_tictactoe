import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/settings_view.dart';
import '../widgets/audio_settings_section.dart';
import '../widgets/language_selector.dart';

/// Settings page for changing app language.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsView(
      onBack: () => context.pop(),
      languageSelector: const LanguageSelector(),
      audioSettings: const AudioSettingsSection(),
    );
  }
}

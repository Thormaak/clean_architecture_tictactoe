import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/extensions/build_context_extensions.dart';
import '../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../core/presentation/theme/layout_tokens.dart';
import '../../../../core/presentation/widgets/widgets.dart';

/// Pure presentation view for settings screen.
class SettingsView extends StatelessWidget {
  final VoidCallback onBack;
  final Widget languageSelector;
  final Widget audioSettings;

  const SettingsView({
    super.key,
    required this.onBack,
    required this.languageSelector,
    required this.audioSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GamingScaffold(
      child: SafeArea(
        child: Column(
          children: [
            GamingHeaderRow(title: l10n.settings, onBack: onBack),
            // Content
            Expanded(
              child: _SettingsContent(
                l10n: l10n,
                languageSelector: languageSelector,
                audioSettings: audioSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final AppLocalizations l10n;
  final Widget languageSelector;
  final Widget audioSettings;

  const _SettingsContent({
    required this.l10n,
    required this.languageSelector,
    required this.audioSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = context.isLargeScreen;
    final horizontalPadding =
        isLargeScreen
            ? 48.0
            : LayoutTokens.pagePaddingHorizontal.horizontal / 2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isLargeScreen ? 1000 : 600),
          child:
              isLargeScreen
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LanguageSection(
                          l10n: l10n,
                          languageSelector: languageSelector,
                        ),
                      ),
                      const SizedBox(width: LayoutTokens.spacingXl),
                      Expanded(
                        child: _AudioSection(audioSettings: audioSettings),
                      ),
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: LayoutTokens.spacingXl),
                      _LanguageSection(
                        l10n: l10n,
                        languageSelector: languageSelector,
                      ),
                      const SizedBox(height: LayoutTokens.spacingXl),
                      _AudioSection(audioSettings: audioSettings),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  final AppLocalizations l10n;
  final Widget languageSelector;

  const _LanguageSection({required this.l10n, required this.languageSelector});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: LayoutTokens.spacingXl),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(
            delay:
                LayoutTokens.durationFast + const Duration(milliseconds: 100),
            duration: LayoutTokens.durationMedium,
          ),
        ),
        const SizedBox(height: LayoutTokens.spacingMd),
        languageSelector
            .animate()
            .fadeIn(
              delay: LayoutTokens.durationNormal,
              duration: LayoutTokens.durationMedium,
            )
            .slideY(begin: 0.1),
      ],
    );
  }
}

class _AudioSection extends StatelessWidget {
  final Widget audioSettings;

  const _AudioSection({required this.audioSettings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: LayoutTokens.spacingXl),
        audioSettings
            .animate()
            .fadeIn(
              delay:
                  LayoutTokens.durationNormal +
                  const Duration(milliseconds: 50),
              duration: LayoutTokens.durationMedium,
            )
            .slideY(begin: 0.1),
      ],
    );
  }
}

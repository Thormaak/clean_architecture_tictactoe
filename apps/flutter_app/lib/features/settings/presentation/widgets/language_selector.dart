import 'package:flutter/material.dart';
import '../../../../core/presentation/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';

/// Widget to select the app language (English or French)
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeAsync = ref.watch(localeProvider);
    final currentLocale =
        localeAsync.hasValue
            ? localeAsync.value
            : null; // Peut être null pendant le chargement

    // Get system locale if no locale is set
    final effectiveLocale = currentLocale ?? Localizations.localeOf(context);

    return Column(
      children: [
        _LanguageOption(
          flag: '\u{1F1EC}\u{1F1E7}',
          label: l10n.languageEnglish,
          isSelected: effectiveLocale.languageCode == 'en',
          onTap:
              () => ref
                  .read(localeProvider.notifier)
                  .setLocale(const Locale('en')),
        ),
        const SizedBox(height: 8),
        _LanguageOption(
          flag: '\u{1F1EB}\u{1F1F7}',
          label: l10n.languageFrench,
          isSelected: effectiveLocale.languageCode == 'fr',
          onTap:
              () => ref
                  .read(localeProvider.notifier)
                  .setLocale(const Locale('fr')),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      trailing:
          isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
      selected: isSelected,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}

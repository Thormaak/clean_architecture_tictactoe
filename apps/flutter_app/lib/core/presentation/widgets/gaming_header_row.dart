import 'package:flutter/material.dart';

import '../theme/gaming_theme.dart';
import '../theme/layout_tokens.dart';
import 'gaming_icon_button.dart';

/// Reusable header row with optional back and settings buttons.
class GamingHeaderRow extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final Widget? center;
  final Color settingsColor;

  const GamingHeaderRow({
    super.key,
    this.title,
    this.onBack,
    this.onSettings,
    this.center,
    this.settingsColor = GamingTheme.accentPink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: LayoutTokens.headerPadding,
      child: Row(
        children: [
          _HeaderSlot(
            child:
                onBack == null
                    ? null
                    : GamingIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: onBack,
                      size: 40,
                    ),
          ),
          Expanded(
            child: Center(
              child:
                  center ??
                  (title == null
                      ? const SizedBox.shrink()
                      : Text(
                        title!,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
            ),
          ),
          _HeaderSlot(
            child:
                onSettings == null
                    ? null
                    : GamingIconButton.header(
                      icon: Icons.settings_rounded,
                      color: settingsColor,
                      onTap: onSettings,
                    ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSlot extends StatelessWidget {
  final Widget? child;

  const _HeaderSlot({this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 48, height: 48, child: child);
  }
}

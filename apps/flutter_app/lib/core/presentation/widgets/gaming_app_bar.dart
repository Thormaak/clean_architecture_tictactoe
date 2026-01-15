import 'package:flutter/material.dart';

import 'gaming_icon_button.dart';

/// Transparent AppBar with centered title and optional back button.
class GamingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final Widget? title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const GamingAppBar({
    super.key,
    this.titleText,
    this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final titleWidget =
        title ??
        (titleText == null
            ? null
            : Text(
              titleText!,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ));

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: titleWidget,
      leading:
          onBack == null
              ? const SizedBox(width: 48)
              : Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GamingIconButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: onBack,
                  size: 40,
                ),
              ),
      actions: [if (trailing != null) trailing! else const SizedBox(width: 48)],
    );
  }
}

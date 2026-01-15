import 'package:flutter/material.dart';

import '../theme/gaming_theme.dart';

/// Scaffold with the common gaming background gradient
class GamingScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const GamingScaffold({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: GamingTheme.pageBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: child,
      ),
    );
  }
}

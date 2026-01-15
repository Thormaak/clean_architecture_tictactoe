import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictactoe/core/application/router/app_router.dart';
import 'package:tictactoe/core/presentation/l10n/app_localizations.dart';
import 'package:tictactoe/core/presentation/theme/gaming_theme.dart';

import 'features/settings/presentation/providers/locale_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final localeAsync = ref.watch(localeProvider);
    final locale = localeAsync.hasValue ? localeAsync.value : null;

    return MaterialApp.router(
      title: 'TicTacToe',
      debugShowCheckedModeBanner: false,
      theme: GamingTheme.darkTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fr')],
      routerConfig: router,
    );
  }
}

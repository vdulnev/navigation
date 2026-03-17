import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'core/talker.dart';
import 'router/app_router.dart';

/// App root.
///
/// Beamer tab pattern used here:
///
/// * **[MaterialApp.router] + root [BeamerDelegate]**: provides the top-level
///   [Router] widget that nested [Beamer] tab widgets require as an ancestor.
///   Without this, `Router.of(context)` inside each tab's [Beamer] would fail.
///
/// * **Imperative push for login / logs**: [MaterialApp.router] does not
///   support [onGenerateRoute], so modal screens are pushed via
///   `Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(…))`
///   directly from the calling screens — no named-route registration needed.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delegate = ref.watch(rootDelegateProvider);

    return TalkerWrapper(
      talker: talker,
      options: const TalkerWrapperOptions(enableErrorAlerts: true),
      child: MaterialApp.router(
        title: 'Shop — Beamer + Riverpod',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ),
    );
  }
}

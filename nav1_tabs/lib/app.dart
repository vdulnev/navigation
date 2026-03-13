import 'package:flutter/material.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/shell/screens/shell_screen.dart';
import 'router/app_routes.dart';

/// Root widget — owns the MaterialApp and the **top-level** Navigator route
/// table.
///
/// Only two routes live here:
///   • [AppRoutes.shell]  — the tab scaffold, always the initial route.
///   • [AppRoutes.login]  — pushed as a fullscreen dialog via
///     `rootNavigator: true` from any tab screen.
///
/// Each tab manages its own internal routes inside its own [Navigator] widget
/// declared in [ShellScreen]. Routes pushed via `rootNavigator: true` target
/// *this* Navigator, which is why login appears above the entire tab UI.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop — Navigator 1 Tabs',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      initialRoute: AppRoutes.shell,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<Object?> _onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.shell => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ShellScreen(),
      ),
      // fullscreenDialog: true gives the login screen the modal "slide up"
      // animation and a close (✕) button instead of a back arrow.
      AppRoutes.login => MaterialPageRoute<bool>(
        fullscreenDialog: true,
        settings: settings,
        builder: (_) => const LoginScreen(),
      ),
      _ => MaterialPageRoute<void>(builder: (_) => const ShellScreen()),
    };
  }
}

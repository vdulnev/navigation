import 'package:flutter/material.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'router/app_routes.dart';

/// Root widget that owns the [MaterialApp] and the Navigator 1 route table.
///
/// All named routes are declared in [onGenerateRoute] using a switch, which
/// gives us one place to see every destination in the app.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigator 1 Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<Object?> _onGenerateRoute(RouteSettings settings) {
    // Switch on route name so every destination is visible in one place.
    final Widget page = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.login => const LoginScreen(),
      AppRoutes.home => const HomeScreen(),
      AppRoutes.profile => const ProfileScreen(),
      AppRoutes.editProfile => const EditProfileScreen(),
      AppRoutes.settings => const SettingsScreen(),
      _ => const _NotFoundScreen(),
    };

    return MaterialPageRoute<Object?>(
      settings: settings, // forward settings so arguments are accessible
      builder: (_) => page,
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(child: Text('404 – Route not found')),
    );
  }
}

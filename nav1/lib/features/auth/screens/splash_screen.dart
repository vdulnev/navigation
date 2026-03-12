import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';
import '../services/auth_service.dart';

/// Shown briefly at startup.
///
/// Navigator 1 concept demonstrated: [Navigator.pushReplacementNamed] —
/// the splash screen replaces itself so the user cannot navigate back to it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final destination = AuthService.isLoggedIn
        ? AppRoutes.home
        : AppRoutes.login;

    // pushReplacementNamed: replaces the current route so Back is not shown.
    Navigator.of(context).pushReplacementNamed(destination);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterLogo(size: 80),
            SizedBox(height: 24),
            Text(
              'Navigator 1 Demo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

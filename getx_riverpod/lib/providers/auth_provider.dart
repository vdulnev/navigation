import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../router/app_routes.dart';

sealed class AuthResult {
  const AuthResult();
}

final class AuthSuccess extends AuthResult {
  const AuthSuccess();
}

final class AuthError extends AuthResult {
  const AuthError(this.message);

  final String message;
}

/// Riverpod 3 state for authentication.
///
/// [AuthNotifier] owns the single source of truth for whether the user is
/// logged in. All screens that gate content on auth status watch this provider
/// and rebuild automatically — no manual setState() needed.
final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Accepts any non-empty credentials with a valid email. Returns
  /// [AuthSuccess] or [AuthError].
  Future<AuthResult> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.isNotEmpty) {
      if (!email.contains('@')) {
        return const AuthError('Enter a valid email address.');
      }
      state = true;
      return const AuthSuccess();
    }
    return const AuthError('Invalid credentials. Try any non-empty values.');
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = false;
  }

  void navigateToLogin() => Get.toNamed(AppRoutes.login);
}

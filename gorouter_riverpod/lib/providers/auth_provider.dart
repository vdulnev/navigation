import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// [AuthNotifier] is the single source of truth for login status.
/// [RouterNotifier] listens to this provider and triggers GoRouter to
/// re-evaluate its redirect callbacks whenever the value changes.
final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Validates credentials and returns [AuthSuccess] or [AuthError].
  ///
  /// Does NOT update [state] — call [setLoggedIn] after navigation so that
  /// GoRouter's [RouterNotifier] fires after `context.pop()`, not before.
  Future<AuthResult> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.isNotEmpty) {
      if (!email.contains('@')) {
        return const AuthError('Enter a valid email address.');
      }
      return const AuthSuccess();
    }
    return const AuthError('Invalid credentials. Try any non-empty values.');
  }

  /// Sets auth state to true. Call this AFTER `context.pop()` so that
  /// GoRouter rebuilds from the correct route, not from `/login`.
  void setLoggedIn() => state = true;

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = false;
  }
}

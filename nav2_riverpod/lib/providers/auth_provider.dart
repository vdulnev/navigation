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
/// [NavigationNotifier] listens to this provider and resets navigation state
/// whenever the value changes (e.g. on logout).
final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Validates credentials and returns [AuthSuccess] or [AuthError].
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

  /// Sets auth state to true after login succeeds.
  void setLoggedIn() => state = true;

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = false;
  }
}

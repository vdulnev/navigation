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
/// Beamer delegates and [BeamGuard]s read this provider to decide
/// whether to allow or block navigation to protected routes.
final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Validates credentials and returns [AuthSuccess] or [AuthError].
  ///
  /// Does NOT update [state] — call [setLoggedIn] after navigation so that
  /// the route stack is correct before auth state fires listeners.
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

  /// Sets auth state to true. Call this AFTER [Navigator.pop] so that
  /// listeners fire after the route stack is restored, not before.
  void setLoggedIn() => state = true;

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = false;
  }
}

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

final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<AuthResult> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.isNotEmpty) {
      if (!email.contains('@')) {
        return const AuthError('Enter a valid email address.');
      }
      state = true; // Safe in AutoRoute — no URL reconstruction issue
      return const AuthSuccess();
    }
    return const AuthError('Invalid credentials. Try any non-empty values.');
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = false;
  }
}

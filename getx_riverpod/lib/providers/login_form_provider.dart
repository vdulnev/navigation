import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

@immutable
class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.loading = false,
    this.serverError,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool loading;
  final String? serverError;
}

/// Owns all login form state: field values, field-level validation errors,
/// loading flag, and server error.
///
/// autoDispose resets cleanly when LoginScreen is popped.
///
/// The widget needs no GlobalKey, no TextEditingController, no setState —
/// it reads state from this provider and writes via setEmail/setPassword/submit.
final loginFormProvider =
    NotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>(
      LoginFormNotifier.new,
    );

class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void setEmail(String v) {
    state = LoginFormState(
      email: v,
      emailError: v.isEmpty ? 'Enter an email' : null,
      password: state.password,
      passwordError: state.passwordError,
      serverError: state.serverError,
    );
  }

  void setPassword(String v) {
    state = LoginFormState(
      email: state.email,
      emailError: state.emailError,
      password: v,
      passwordError: v.isEmpty ? 'Enter a password' : null,
      serverError: state.serverError,
    );
  }

  /// Validates both fields, then calls [authProvider] login.
  /// Returns true on success so the widget can call Get.back.
  Future<bool> submit() async {
    final email = state.email;
    final password = state.password;

    final emailErr = email.isEmpty ? 'Enter an email' : null;
    final passErr = password.isEmpty ? 'Enter a password' : null;

    if (emailErr != null || passErr != null) {
      state = LoginFormState(
        email: email,
        emailError: emailErr,
        password: password,
        passwordError: passErr,
      );
      return false;
    }

    state = LoginFormState(email: email, password: password, loading: true);
    final ok = await ref.read(authProvider.notifier).login(email, password);

    if (ok) {
      state = const LoginFormState();
      return true;
    }

    state = LoginFormState(
      email: email,
      password: password,
      serverError: 'Invalid credentials. Try any non-empty values.',
    );
    return false;
  }
}

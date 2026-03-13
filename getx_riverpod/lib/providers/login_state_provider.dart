import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

/// Error message
///
/// client-side validation (empty fields).
/// server rejected the credentials.
sealed class LoginFormError {
  const LoginFormError();
}

class LoginCredentialsError extends LoginFormError {
  const LoginCredentialsError();
}

class LoginServerError extends LoginFormError {
  const LoginServerError(this.message);

  final String message;
}

/// Sealed hierarchy — exhaustive pattern matching enforced by the compiler.
///
/// Three states:
/// • [LoginFormEditing]    — clean form, no errors visible.
/// • [LoginFormInvalid]    — errors visible; kind determined by [LoginFormErrors].
/// • [LoginFormSubmitting] — network call in flight.
sealed class LoginFormState {
  const LoginFormState();
}

/// User is editing the form. Field values only — no errors shown.
final class LoginFormEditing extends LoginFormState {
  const LoginFormEditing({this.email = '', this.password = ''});

  final String email;
  final String password;
}

/// A submit attempt revealed errors. The error kind is in [error].
final class LoginFormInvalid extends LoginFormState {
  const LoginFormInvalid({
    required this.email,
    required this.password,
    required this.error,
  });

  final String email;
  final String password;
  final LoginFormError error;
}

/// Network call in flight — UI disables input and shows a spinner.
final class LoginFormSubmitting extends LoginFormState {
  const LoginFormSubmitting();
}

final loginStateProvider =
    NotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>(
      LoginFormNotifier.new,
    );

class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormEditing();

  void setEmail(String v) {
    switch (state) {
      case LoginFormEditing(:final password):
        state = v.isEmpty
            ? LoginFormInvalid(
                email: v,
                password: password,
                error: const LoginCredentialsError(),
              )
            : LoginFormEditing(email: v, password: password);

      // Nested pattern: alias the inner `password` field to avoid shadowing.
      case LoginFormInvalid(
        :final password,
        error: LoginCredentialsError(),
      ):
        final emailError = v.isEmpty ? 'Enter an email' : null;
        final passwordError = password.isEmpty ? 'Enter password' : null;
        if (emailError == null && passwordError == null) {
          state = LoginFormEditing(email: v, password: password);
        } else {
          state = LoginFormInvalid(
            email: v,
            password: password,
            error: LoginCredentialsError(),
          );
        }

      case LoginFormInvalid(:final password, error: LoginServerError()):
        // Any keystroke clears the server error — return to clean editing.
        state = LoginFormEditing(email: v, password: password);

      case LoginFormSubmitting():
        break;
    }
  }

  void setPassword(String v) {
    switch (state) {
      case LoginFormEditing(:final email):
        state = v.isEmpty
            ? LoginFormInvalid(
                email: email,
                password: v,
                error: const LoginCredentialsError(),
              )
            : LoginFormEditing(email: email, password: v);

      // Alias the inner `email` field to avoid shadowing.
      case LoginFormInvalid(
        :final email,
        error: LoginCredentialsError(),
      ):
        final passwordError = v.isEmpty ? 'Enter a password' : null;
        final emailError = email.isEmpty ? 'Enter a password' : null;
        if (emailError == null && passwordError == null) {
          state = LoginFormEditing(email: email, password: v);
        } else {
          state = LoginFormInvalid(
            email: email,
            password: v,
            error: LoginCredentialsError(),
          );
        }

      case LoginFormInvalid(:final email, error: LoginServerError()):
        state = LoginFormEditing(email: email, password: v);

      case LoginFormSubmitting():
        break;
    }
  }

  Future<bool> submit() async {
    final s = state;
    final String email;
    final String password;
    switch (s) {
      case LoginFormEditing():
        email = s.email;
        password = s.password;
      case LoginFormInvalid():
        email = s.email;
        password = s.password;
      case LoginFormSubmitting():
        return false;
    }

    final emailErr = email.isEmpty ? 'Enter an email' : null;
    final passErr = password.isEmpty ? 'Enter a password' : null;

    if (emailErr != null || passErr != null) {
      state = LoginFormInvalid(
        email: email,
        password: password,
        error: LoginCredentialsError(),
      );
      return false;
    }

    state = const LoginFormSubmitting();
    final ok = await ref.read(authProvider.notifier).login(email, password);

    if (ok) {
      state = const LoginFormEditing();
      return true;
    }

    state = LoginFormInvalid(
      email: email,
      password: password,
      error: const LoginServerError(
        'Invalid credentials. Try any non-empty values.',
      ),
    );
    return false;
  }
}

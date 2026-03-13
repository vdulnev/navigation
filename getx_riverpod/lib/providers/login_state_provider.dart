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

/// Returns [LoginCredentialsError] if either field is empty, otherwise null.
/// Single source of truth for field-level validation rules.
LoginCredentialsError? _validate(String email, String password) =>
    (email.isEmpty || password.isEmpty) ? const LoginCredentialsError() : null;

class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormEditing();

  void setEmail(String v) {
    switch (state) {
      case LoginFormEditing(:final password):
      case LoginFormInvalid(:final password, error: LoginCredentialsError()):
        final error = _validate(v, password);
        state = error != null
            ? LoginFormInvalid(email: v, password: password, error: error)
            : LoginFormEditing(email: v, password: password);

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
      case LoginFormInvalid(:final email, error: LoginCredentialsError()):
        final error = _validate(email, v);
        state = error != null
            ? LoginFormInvalid(email: email, password: v, error: error)
            : LoginFormEditing(email: email, password: v);

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

    final error = _validate(email, password);
    if (error != null) {
      state = LoginFormInvalid(email: email, password: password, error: error);
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

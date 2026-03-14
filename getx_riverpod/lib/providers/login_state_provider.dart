import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

// ---------------------------------------------------------------------------
// Error types
// ---------------------------------------------------------------------------

sealed class LoginFormError {
  const LoginFormError();
}

/// Client-side validation failed — one or both fields are empty.
final class LoginCredentialsError extends LoginFormError {
  const LoginCredentialsError();
}

/// Server rejected the credentials after a network call.
final class LoginServerError extends LoginFormError {
  const LoginServerError(this.message);

  final String message;
}

// ---------------------------------------------------------------------------
// Validation — single source of truth for field rules.
// ---------------------------------------------------------------------------

/// Returns [LoginCredentialsError] if either field is empty, otherwise null.
LoginCredentialsError? _validate(String email, String password) =>
    (email.isEmpty || password.isEmpty) ? const LoginCredentialsError() : null;

// ---------------------------------------------------------------------------
// State hierarchy — each subclass owns its own transition logic (State pattern).
// The notifier becomes a thin dispatcher: state = state.onXxx(v).
// ---------------------------------------------------------------------------

/// Sealed base. Declares the events every state must handle.
///
/// • [onEmailChanged] / [onPasswordChanged] — keystroke from the UI.
/// • [credentials] — (email, password) pair for submission; null while
///   a network call is already in flight.
sealed class LoginFormState {
  const LoginFormState();

  LoginFormState onEmailChanged(String v);
  LoginFormState onPasswordChanged(String v);

  /// Returns the (email, password) ready for submission, or null if
  /// submission is not possible (already in flight).
  (String email, String password)? get credentials;
}

/// User is editing the form. No errors shown.
final class LoginFormEditing extends LoginFormState {
  const LoginFormEditing({this.email = '', this.password = ''});

  final String email;
  final String password;

  @override
  LoginFormState onEmailChanged(String v) {
    final error = _validate(v, password);
    return error != null
        ? LoginFormInvalid(email: v, password: password, error: error)
        : LoginFormEditing(email: v, password: password);
  }

  @override
  LoginFormState onPasswordChanged(String v) {
    final error = _validate(email, v);
    return error != null
        ? LoginFormInvalid(email: email, password: v, error: error)
        : LoginFormEditing(email: email, password: v);
  }

  @override
  (String, String) get credentials => (email, password);
}

/// Errors are visible. The error kind is in [error].
final class LoginFormInvalid extends LoginFormState {
  const LoginFormInvalid({
    required this.email,
    required this.password,
    required this.error,
  });

  final String email;
  final String password;
  final LoginFormError error;

  @override
  LoginFormState onEmailChanged(String v) => switch (error) {
    LoginCredentialsError() => _revalidate(email: v, password: password),
    // Any keystroke clears the server error — return to clean editing.
    LoginServerError() => LoginFormEditing(email: v, password: password),
  };

  @override
  LoginFormState onPasswordChanged(String v) => switch (error) {
    LoginCredentialsError() => _revalidate(email: email, password: v),
    LoginServerError() => LoginFormEditing(email: email, password: v),
  };

  LoginFormState _revalidate({
    required String email,
    required String password,
  }) {
    final err = _validate(email, password);
    return err != null
        ? LoginFormInvalid(email: email, password: password, error: err)
        : LoginFormEditing(email: email, password: password);
  }

  @override
  (String, String) get credentials => (email, password);
}

/// Network call in flight — input is ignored.
final class LoginFormSubmitting extends LoginFormState {
  const LoginFormSubmitting();

  @override
  LoginFormState onEmailChanged(String v) => this;

  @override
  LoginFormState onPasswordChanged(String v) => this;

  @override
  (String, String)? get credentials => null;
}

// ---------------------------------------------------------------------------
// Provider + notifier
// ---------------------------------------------------------------------------

final loginStateProvider =
    NotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>(
      LoginFormNotifier.new,
    );

/// Thin dispatcher — all transition logic lives in the state classes.
class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormEditing();

  void setEmail(String v) => state = state.onEmailChanged(v);
  void setPassword(String v) => state = state.onPasswordChanged(v);

  Future<bool> submit() async {
    // credentials returns null when already submitting.
    final creds = state.credentials;
    if (creds == null) return false;
    final (email, password) = creds;

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

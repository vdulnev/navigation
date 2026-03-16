import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart' show AuthError, AuthSuccess, authProvider;

/// Client-side validation.
sealed class LoginCredentialsResult {
  const LoginCredentialsResult();
}

/// Client-side validation ok.
final class LoginCredentialsCorrect extends LoginCredentialsResult {
  const LoginCredentialsCorrect({required this.email, required this.password});

  final String email;
  final String password;
}

/// Client-side validation failed — carries per-field messages.
final class LoginCredentialsError extends LoginCredentialsResult {
  const LoginCredentialsError({required this.email, required this.password});

  final String? email;
  final String? password;

  String? get emailError => email?.isNotEmpty == true ? null : 'Enter an email';
  String? get passwordError =>
      password?.isNotEmpty == true ? null : 'Enter a password';
}

/// Server rejected the credentials after a network call.
final class LoginServerError {
  const LoginServerError({required this.message});

  final String message;
}

// ---------------------------------------------------------------------------
// Validation — single source of truth for field rules.
// ---------------------------------------------------------------------------

/// Returns [LoginCredentialsError] with per-field messages, or null if valid.
LoginCredentialsResult _validate(String? email, String? password) {
  if ((email != null && email.isNotEmpty) &&
      (password != null && password.isNotEmpty)) {
    return LoginCredentialsCorrect(email: email, password: password);
  }
  return LoginCredentialsError(email: email, password: password);
}

/// Validates [email] and [password], returning the appropriate state.
LoginFormState _revalidate(String? email, String? password) {
  final result = _validate(email, password);
  switch (result) {
    case LoginCredentialsCorrect(:final email, :final password):
      return LoginFormCorrect(email: email, password: password);
    case final LoginCredentialsError credError:
      return LoginFormEditing(
        email: credError.email,
        password: credError.password,
        error: credError,
      );
  }
}

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
}

/// User is editing the form. No errors shown.
final class LoginFormEditing extends LoginFormState {
  const LoginFormEditing({this.email, this.password, this.error});

  final String? email;
  final String? password;
  final LoginCredentialsError? error;

  @override
  LoginFormState onEmailChanged(String v) => _revalidate(v, password);

  @override
  LoginFormState onPasswordChanged(String v) => _revalidate(email, v);
}

/// Form is correct.
final class LoginFormCorrect extends LoginFormState {
  const LoginFormCorrect({required this.email, required this.password});

  final String email;
  final String password;

  @override
  LoginFormState onEmailChanged(String v) => _revalidate(v, password);

  @override
  LoginFormState onPasswordChanged(String v) => _revalidate(email, v);

  (String, String) get credentials => (email, password);
}

/// Errors are visible. [error] carries both the input values and the error
/// kind — pattern-match on the subclass to access them.
final class LoginFormInvalid extends LoginFormState {
  const LoginFormInvalid({required this.error});

  final LoginServerError error;

  @override
  LoginFormState onEmailChanged(String v) => _revalidate(v, null);

  @override
  LoginFormState onPasswordChanged(String v) => _revalidate(null, v);
}

/// Network call in flight — input is ignored.
final class LoginFormSubmitting extends LoginFormState {
  const LoginFormSubmitting();

  @override
  LoginFormState onEmailChanged(String v) => this;

  @override
  LoginFormState onPasswordChanged(String v) => this;
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
    final aState = state;
    if (aState is LoginFormCorrect) {
      final creds = aState.credentials;
      final (email, password) = creds;

      state = const LoginFormSubmitting();
      switch (await ref.read(authProvider.notifier).login(email, password)) {
        case AuthSuccess():
          state = const LoginFormEditing();
          return true;
        case AuthError(:final message):
          state = LoginFormInvalid(error: LoginServerError(message: message));
          return false;
      }
    } else {
      return false;
    }
  }
}

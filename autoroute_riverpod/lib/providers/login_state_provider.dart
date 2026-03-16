import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart' show AuthError, AuthSuccess, authProvider;

/// Client-side validation result.
sealed class LoginCredentialsResult {
  const LoginCredentialsResult();
}

/// Both fields are non-empty.
final class LoginCredentialsCorrect extends LoginCredentialsResult {
  const LoginCredentialsCorrect({required this.email, required this.password});

  final String email;
  final String password;
}

/// One or more fields are empty — carries per-field error messages.
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

LoginCredentialsResult _validate(String? email, String? password) {
  if ((email != null && email.isNotEmpty) &&
      (password != null && password.isNotEmpty)) {
    return LoginCredentialsCorrect(email: email, password: password);
  }
  return LoginCredentialsError(email: email, password: password);
}

/// Validates [email] and [password], returning the appropriate form state.
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
// ---------------------------------------------------------------------------

/// Sealed base. Each subclass handles keystroke events and owns its
/// transition logic — the notifier is a thin dispatcher.
sealed class LoginFormState {
  const LoginFormState();

  LoginFormState onEmailChanged(String v);
  LoginFormState onPasswordChanged(String v);
}

/// User is editing the form; [error] carries per-field messages when present.
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

/// Both fields are valid — ready to submit.
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

/// Server returned an error; [error] carries the message.
final class LoginFormInvalid extends LoginFormState {
  const LoginFormInvalid({required this.error});

  final LoginServerError error;

  @override
  LoginFormState onEmailChanged(String v) => _revalidate(v, null);

  @override
  LoginFormState onPasswordChanged(String v) => _revalidate(null, v);
}

/// Network call in flight — keystrokes are ignored.
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
///
/// [submit] returns true on success. Navigation is handled by the widget
/// (context.router.pop(true)) because AutoRoute requires a [BuildContext].
class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormEditing();

  void setEmail(String v) => state = state.onEmailChanged(v);
  void setPassword(String v) => state = state.onPasswordChanged(v);

  Future<bool> submit() async {
    final aState = state;
    if (aState is! LoginFormCorrect) return false;
    final (email, password) = aState.credentials;
    state = const LoginFormSubmitting();
    switch (await ref.read(authProvider.notifier).login(email, password)) {
      case AuthSuccess():
        state = const LoginFormEditing();
        return true;
      case AuthError(:final message):
        state = LoginFormInvalid(error: LoginServerError(message: message));
        return false;
    }
  }
}

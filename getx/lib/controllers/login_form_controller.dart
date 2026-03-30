import 'package:get/get.dart';

import 'auth_controller.dart' show AuthController, AuthError, AuthSuccess;

/// Client-side validation ok.
final class LoginCredentialsCorrect {
  const LoginCredentialsCorrect({required this.email, required this.password});

  final String email;
  final String password;
}

/// Client-side validation failed — carries per-field messages.
final class LoginCredentialsError {
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
// Validation
// ---------------------------------------------------------------------------

LoginFormState _revalidate(String? email, String? password) {
  if ((email != null && email.isNotEmpty) &&
      (password != null && password.isNotEmpty)) {
    return LoginFormCorrect(email: email, password: password);
  }
  return LoginFormEditing(
    email: email,
    password: password,
    error: LoginCredentialsError(email: email, password: password),
  );
}

// ---------------------------------------------------------------------------
// State hierarchy — same State pattern as the Riverpod variant.
// ---------------------------------------------------------------------------

sealed class LoginFormState {
  const LoginFormState();

  LoginFormState onEmailChanged(String v);
  LoginFormState onPasswordChanged(String v);
}

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

final class LoginFormInvalid extends LoginFormState {
  const LoginFormInvalid({required this.error});

  final LoginServerError error;

  @override
  LoginFormState onEmailChanged(String v) => _revalidate(v, null);

  @override
  LoginFormState onPasswordChanged(String v) => _revalidate(null, v);
}

final class LoginFormSubmitting extends LoginFormState {
  const LoginFormSubmitting();

  @override
  LoginFormState onEmailChanged(String v) => this;

  @override
  LoginFormState onPasswordChanged(String v) => this;
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

/// GetX controller for the login form.
///
/// Uses `Rx<LoginFormState>` so `Obx` rebuilds on every state transition.
/// The sealed state hierarchy and State pattern are identical to the Riverpod
/// variant — only the reactive wrapper changes.
class LoginFormController extends GetxController {
  final Rx<LoginFormState> state = Rx<LoginFormState>(const LoginFormEditing());

  void setEmail(String v) => state.value = state.value.onEmailChanged(v);
  void setPassword(String v) => state.value = state.value.onPasswordChanged(v);

  Future<void> submit() async {
    final current = state.value;
    if (current is! LoginFormCorrect) return;

    final (email, password) = current.credentials;
    state.value = const LoginFormSubmitting();

    final auth = Get.find<AuthController>();
    switch (await auth.login(email, password)) {
      case AuthSuccess():
        state.value = const LoginFormEditing();
        Get.back<bool>(result: true);
      case AuthError(:final message):
        state.value = LoginFormInvalid(
          error: LoginServerError(message: message),
        );
    }
  }

  void reset() => state.value = const LoginFormEditing();
}

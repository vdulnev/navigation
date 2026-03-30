import 'package:get/get.dart';

import '../router/app_routes.dart';

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

/// GetX controller for authentication state.
///
/// [isLoggedIn] is an `.obs` bool — any `Obx` that reads it rebuilds
/// automatically when login/logout changes the value.
class AuthController extends GetxController {
  final isLoggedIn = false.obs;

  Future<AuthResult> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.isNotEmpty) {
      if (!email.contains('@')) {
        return const AuthError('Enter a valid email address.');
      }
      isLoggedIn.value = true;
      return const AuthSuccess();
    }
    return const AuthError('Invalid credentials. Try any non-empty values.');
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    isLoggedIn.value = false;
  }

  void navigateToLogin() => Get.toNamed(AppRoutes.login);
}

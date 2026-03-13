import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod 3 state for authentication.
///
/// [AuthNotifier] owns the single source of truth for whether the user is
/// logged in. All screens that gate content on auth status watch this provider
/// and rebuild automatically — no manual setState() needed.
final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Accepts any non-empty credentials. Returns true on success.
  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.isNotEmpty) {
      state = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = false;
  }
}

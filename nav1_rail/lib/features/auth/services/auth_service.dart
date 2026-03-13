/// Mock authentication service — no real network calls.
class AuthService {
  static bool _loggedIn = false;

  static bool get isLoggedIn => _loggedIn;

  /// Returns true on success. Accepts any non-empty credentials.
  static Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.isNotEmpty) {
      _loggedIn = true;
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _loggedIn = false;
  }
}

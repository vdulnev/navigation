/// Named route constants for the app.
///
/// The MaterialApp's root Navigator owns [shell] and [login].
/// Each section's own Navigator owns its section-level routes.
abstract class AppRoutes {
  // ── Root Navigator routes ─────────────────────────────────────────────────
  /// The rail scaffold. Always the initial route.
  static const shell = '/';

  /// Login screen. Pushed via rootNavigator: true so it sits above the rail.
  static const login = '/login';

  // ── Shop section Navigator routes ─────────────────────────────────────────
  /// Product detail, pushed inside the shop (or search) section's Navigator.
  static const shopDetail = '/detail';

  // ── Basket section Navigator routes ───────────────────────────────────────
  /// Checkout screen, pushed inside the basket section's Navigator.
  static const checkout = '/checkout';
}

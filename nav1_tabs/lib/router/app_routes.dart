/// Named route constants for the app.
///
/// The MaterialApp's root Navigator owns [shell] and [login].
/// Each tab's own Navigator owns its tab-level routes.
abstract class AppRoutes {
  // ── Root Navigator routes ─────────────────────────────────────────────────
  /// The tab scaffold. Always the initial route.
  static const shell = '/';

  /// Login screen. Pushed via rootNavigator: true so it sits above the tabs.
  static const login = '/login';

  // ── Shop tab Navigator routes ─────────────────────────────────────────────
  /// Product detail, pushed inside the shop (or search) tab's Navigator.
  static const shopDetail = '/detail';

  // ── Basket tab Navigator routes ───────────────────────────────────────────
  /// Checkout screen, pushed inside the basket tab's Navigator.
  static const checkout = '/checkout';
}

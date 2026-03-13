/// Named route constants for the app.
///
/// All routes live in the single root [Navigator] — there are no nested
/// navigators in this app. Compare with nav1_tabs where per-tab Navigators
/// required [rootNavigator: true] to reach the root.
abstract class AppRoutes {
  // ── Section routes (top of the back-stack, managed by AppDrawer) ─────────
  static const shop = '/shop';
  static const search = '/search';
  static const basket = '/basket';
  static const account = '/account';

  // ── Detail routes (pushed on top of a section) ────────────────────────────
  static const shopDetail = '/shop/detail';
  static const checkout = '/basket/checkout';

  // ── Modal routes ──────────────────────────────────────────────────────────
  static const login = '/login';
}

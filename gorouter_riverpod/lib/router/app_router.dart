import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/screens/account_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/basket/screens/basket_screen.dart';
import '../features/basket/screens/checkout_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/shell/screens/shell_screen.dart';
import '../features/shop/screens/item_detail_screen.dart';
import '../features/shop/screens/shop_screen.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import 'app_routes.dart';

/// Bridges Riverpod auth state to GoRouter's [refreshListenable].
///
/// When [authProvider] changes, [notifyListeners] is called and GoRouter
/// re-evaluates all [redirect] callbacks — no manual navigation needed.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<bool>(authProvider, (prev, next) => notifyListeners());
  }

  final Ref _ref;

  /// Route-level auth guard.
  ///
  /// Checkout requires login; basket itself stays inside the shell and shows
  /// a sign-in prompt inline so the bottom navigation bar remains visible.
  String? redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _ref.read(authProvider);
    final loc = state.matchedLocation;

    // Only redirect checkout — basket handles unauthenticated state inline.
    if (!isLoggedIn && loc == AppRoutes.checkout) {
      return AppRoutes.basket;
    }
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.shop,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // ── Shell (persistent BottomNavigationBar) ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          // Shop tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shop,
                builder: (context, state) => const ShopScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) =>
                        ItemDetailScreen(product: state.extra! as Product),
                  ),
                ],
              ),
            ],
          ),
          // Search tab — detail pushed within this branch's navigator
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) =>
                        ItemDetailScreen(product: state.extra! as Product),
                  ),
                ],
              ),
            ],
          ),
          // Basket tab (auth-gated via redirect above)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.basket,
                builder: (context, state) => const BasketScreen(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Account tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.account,
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Login — modal, outside the shell ───────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: LoginScreen()),
      ),
    ],
  );
});

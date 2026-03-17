import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------

/// All named route paths used throughout the app.
///
/// Beamer uses these strings as [BeamLocation] URIs on the per-tab
/// delegates. Login and logs are pushed imperatively via the root
/// Navigator — no named route registration needed for them.
abstract final class AppRoutes {
  static const shop = '/';
  static const shopDetail = '/detail';
  static const search = '/search';
  static const searchDetail = '/search/detail';
  static const basket = '/basket';
  static const checkout = '/basket/checkout';
  static const account = '/account';
  static const login = '/login';
  static const logs = '/logs';
}

// ---------------------------------------------------------------------------
// Per-tab delegates
//
// Each tab gets its own [BeamerDelegate] with a [RoutesLocationBuilder].
// This gives every tab an independent Navigator stack — switching tabs
// preserves scroll position and back-stack state, matching the behaviour
// of GoRouter's StatefulShellRoute.indexedStack.
// ---------------------------------------------------------------------------

/// Shop tab delegate — handles `/` (grid) and `/detail` (product page).
///
/// Beamer concept: [RoutesLocationBuilder] matches URI prefixes in order.
/// `data` carries the [Product] object between screens — no path encoding.
BeamerDelegate shopDelegate() => BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': (context, state, data) =>
          const BeamPage(key: ValueKey('shop'), child: ShopScreen()),
      '/detail': (context, state, data) => BeamPage(
        key: const ValueKey('shop-detail'),
        child: ItemDetailScreen(product: data! as Product),
      ),
    },
  ).call,
);

/// Search tab delegate — handles `/search` and `/search/detail`.
BeamerDelegate searchDelegate() => BeamerDelegate(
  initialPath: AppRoutes.search,
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/search': (context, state, data) =>
          const BeamPage(key: ValueKey('search'), child: SearchScreen()),
      '/search/detail': (context, state, data) => BeamPage(
        key: const ValueKey('search-detail'),
        child: ItemDetailScreen(product: data! as Product),
      ),
    },
  ).call,
);

// ---------------------------------------------------------------------------
// Auth guard for checkout
//
// [BeamGuard] is the Beamer equivalent of GoRouter's redirect or AutoRoute's
// AutoRouteGuard. It intercepts navigation before the route is shown.
//
// KEY PATTERN — onCheckFailed with rootNavigator imperative push:
//   Rather than a hard redirect, [onCheckFailed] pushes a MaterialPageRoute
//   onto the *root* Navigator. This keeps the basket tab chrome visible while
//   login is in progress, and lets the guard resume checkout if login succeeds.
//
//   Why imperative push instead of pushNamed:
//   MaterialApp.router does not support onGenerateRoute, so named routes
//   are not available on the root Navigator. Pushing a MaterialPageRoute
//   directly bypasses this limitation while still giving a typed Future<bool>.
//
//   Flow:
//   1. User taps "Proceed to Checkout" → basketDelegate.beamToNamed('/basket/checkout')
//   2. BeamGuard.check fires → authProvider is false → check returns false
//   3. onCheckFailed is called with the basket delegate's context
//   4. Navigator.push<bool>(MaterialPageRoute → LoginScreen) opens modal
//   5. LoginScreen: Navigator.of(context).pop(true) resolves the future
//   6. .then: loggedIn == true → delegate.beamToNamed('/basket/checkout')
// ---------------------------------------------------------------------------

BeamGuard _authGuard(Ref ref) => BeamGuard(
  // Only intercept the checkout path.
  pathPatterns: [AppRoutes.checkout],
  // Return true (allow) if logged in, false (block) otherwise.
  check: (context, location) => ref.read(authProvider),
  // onCheckFailed: push LoginScreen as a modal over the tab shell via the
  // root Navigator, then resume checkout navigation if login succeeds.
  onCheckFailed: (context, location) {
    final delegate = Beamer.of(context);
    Navigator.of(context, rootNavigator: true)
        .push<bool>(
          MaterialPageRoute<bool>(
            fullscreenDialog: true,
            builder: (_) => const LoginScreen(),
          ),
        )
        .then((loggedIn) {
      if (loggedIn == true) {
        delegate.beamToNamed(AppRoutes.checkout);
      }
    });
  },
  replaceCurrentStack: false,
);

/// Basket tab delegate — intercepts `/basket/checkout` with [_authGuard].
BeamerDelegate basketDelegate(Ref ref) => BeamerDelegate(
  initialPath: AppRoutes.basket,
  guards: [_authGuard(ref)],
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/basket': (context, state, data) =>
          const BeamPage(key: ValueKey('basket'), child: BasketScreen()),
      '/basket/checkout': (context, state, data) =>
          const BeamPage(key: ValueKey('checkout'), child: CheckoutScreen()),
    },
  ).call,
);

/// Account tab delegate — handles `/account`.
BeamerDelegate accountDelegate() => BeamerDelegate(
  initialPath: AppRoutes.account,
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/account': (context, state, data) =>
          const BeamPage(key: ValueKey('account'), child: AccountScreen()),
    },
  ).call,
);

// ---------------------------------------------------------------------------
// Root delegate
//
// The root [BeamerDelegate] owns the [ShellScreen] only. Login and the log
// viewer are pushed onto the root Navigator imperatively (MaterialPageRoute)
// from screens that need them — [MaterialApp.router] does not support
// [onGenerateRoute], so named-route pushes on the root Navigator are not
// available. Imperative push<T> still gives a typed Future<bool> return.
// ---------------------------------------------------------------------------

/// Root delegate — mounts [ShellScreen] at `/`.
///
/// Beamer concept: [RoutesLocationBuilder] is used here with a single route.
/// The per-tab [Beamer] widgets inside [ShellScreen] are nested [Router]s
/// that Beamer creates for each [BeamerDelegate], giving each tab its own
/// independent [Navigator] back-stack.
BeamerDelegate rootDelegate() => BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': (context, state, data) =>
          const BeamPage(key: ValueKey('shell'), child: ShellScreen()),
    },
  ).call,
);

/// Root delegate provider — consumed by [App] as the [MaterialApp.router]
/// delegate. Provides the top-level [Router] that nested [Beamer] tab
/// widgets require as an ancestor.
final rootDelegateProvider = Provider<BeamerDelegate>((_) => rootDelegate());

// ---------------------------------------------------------------------------
// Riverpod providers for per-tab delegates — consumed by [ShellScreen].
// ---------------------------------------------------------------------------

/// Per-tab delegate providers — consumed by [ShellScreen].
final shopDelegateProvider = Provider<BeamerDelegate>((_) => shopDelegate());
final searchDelegateProvider = Provider<BeamerDelegate>(
  (_) => searchDelegate(),
);
final basketDelegateProvider = Provider<BeamerDelegate>(
  (ref) => basketDelegate(ref),
);
final accountDelegateProvider = Provider<BeamerDelegate>(
  (_) => accountDelegate(),
);

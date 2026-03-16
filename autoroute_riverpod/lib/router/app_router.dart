import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/account/screens/account_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/basket/screens/basket_screen.dart';
import '../features/basket/screens/checkout_screen.dart';
import '../features/logs/screens/logs_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/shell/screens/shell_screen.dart';
import '../features/shop/screens/item_detail_screen.dart';
import '../features/shop/screens/shop_screen.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';

part 'app_router.gr.dart';

/// Per-tab shell routers — [EmptyShellRoute] creates a nested [AutoRouter]
/// widget for each tab, giving it its own [StackRouter] back-stack.
/// No @RoutePage annotation or separate file needed.
const shopTab = EmptyShellRoute('ShopTab');
const searchTab = EmptyShellRoute('SearchTab');
const basketTab = EmptyShellRoute('BasketTab');
const accountTab = EmptyShellRoute('AccountTab');

/// AutoRoute guard for the checkout route.
///
/// AutoRoute concepts demonstrated:
///
/// * **AutoRouteGuard**: intercepts navigation before the route is shown.
///   [onNavigation] is called with a [NavigationResolver] — call
///   [resolver.next()] to allow or push another route to block.
///
/// * **Guard with Riverpod**: [Ref] is injected so the guard can read
///   Riverpod providers without a [BuildContext].
///
/// Defined in the same file as [AppRouter] to avoid a circular import:
/// [AuthGuard] needs [LoginRoute] (generated into this file's `part`),
/// so it must live here rather than in a separate `auth_guard.dart`.
class AuthGuard extends AutoRouteGuard {
  const AuthGuard(this._ref);

  final Ref _ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_ref.read(authProvider)) {
      resolver.next();
    } else {
      // Push login; on pop, re-check auth and resolve if logged in.
      router.push<bool>(const LoginRoute()).then((loggedIn) {
        if (loggedIn == true) resolver.next();
      });
    }
  }
}

/// AutoRoute router for the online store.
///
/// AutoRoute concepts demonstrated:
///
/// * **@AutoRouterConfig**: annotation triggers code generation via
///   build_runner — produces `app_router.gr.dart` with typed route classes.
///
/// * **EmptyShellRoute**: creates a per-tab [AutoRouter] without a separate
///   file or @RoutePage annotation — the tab gets its own [StackRouter].
///
/// * **AuthGuard on checkout**: the guard intercepts navigation to
///   CheckoutRoute and pushes LoginRoute if the user is not logged in.
///
/// * **fullscreenDialog**: LoginRoute opens as a modal sheet on iOS.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({required this.authGuard});

  final AuthGuard authGuard;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: ShellRoute.page,
      path: '/',
      children: [
        AutoRoute(
          page: shopTab.page,
          path: 'shop',
          initial: true,
          children: [
            AutoRoute(page: ShopRoute.page, path: '', initial: true),
            AutoRoute(page: ItemDetailRoute.page, path: 'detail'),
          ],
        ),
        AutoRoute(
          page: searchTab.page,
          path: 'search',
          children: [
            AutoRoute(page: SearchRoute.page, path: '', initial: true),
            AutoRoute(page: ItemDetailRoute.page, path: 'detail'),
          ],
        ),
        AutoRoute(
          page: basketTab.page,
          path: 'basket',
          children: [
            AutoRoute(page: BasketRoute.page, path: '', initial: true),
            AutoRoute(
              page: CheckoutRoute.page,
              path: 'checkout',
              guards: [authGuard],
            ),
          ],
        ),
        AutoRoute(
          page: accountTab.page,
          path: 'account',
          children: [
            AutoRoute(page: AccountRoute.page, path: '', initial: true),
          ],
        ),
      ],
    ),
    AutoRoute(page: LoginRoute.page, path: '/login', fullscreenDialog: true),
    AutoRoute(page: LogsRoute.page, path: '/logs'),
  ];
}

/// Riverpod provider for the router. Injects [AuthGuard] with a [Ref] so
/// the guard can read Riverpod providers without a [BuildContext].
final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter(authGuard: AuthGuard(ref));
});

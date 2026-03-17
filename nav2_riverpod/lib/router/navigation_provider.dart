import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import 'navigation_state.dart';

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() => const NavigationState();

  // ── Tabs ──────────────────────────────────────────────────────────────────

  void setTab(AppTab tab) {
    if (state.activeTab == tab) {
      // Re-tap active tab → pop to root of that tab
      _popCurrentTabToRoot();
      return;
    }
    state = state.copyWith(activeTab: tab);
  }

  void _popCurrentTabToRoot() {
    switch (state.activeTab) {
      case AppTab.shop:
        state = state.copyWith(shopStack: const [ShopListPage()]);
      case AppTab.search:
        state = state.copyWith(searchStack: const [SearchListPage()]);
      case AppTab.basket:
        state = state.copyWith(basketStack: const [BasketListPage()]);
      case AppTab.account:
        break; // account has no sub-pages
    }
  }

  // ── Shop ──────────────────────────────────────────────────────────────────

  void pushShopDetail(Product product) => state = state.copyWith(
    shopStack: [...state.shopStack, ShopDetailPage(product)],
  );

  void pushSearchDetail(Product product) => state = state.copyWith(
    searchStack: [...state.searchStack, SearchDetailPage(product)],
  );

  // ── Basket ────────────────────────────────────────────────────────────────

  void pushCheckout() {
    if (!ref.read(authProvider)) {
      // Not logged in — show login first; guard retries checkout on success
      _pendingCheckout = true;
      state = state.copyWith(showLogin: true);
      return;
    }
    state = state.copyWith(
      activeTab: AppTab.basket,
      basketStack: const [BasketListPage(), CheckoutPage()],
    );
  }

  bool _pendingCheckout = false;

  // ── Login ─────────────────────────────────────────────────────────────────

  void showLogin() => state = state.copyWith(showLogin: true);

  /// Called by LoginScreen when login succeeds.
  void onLoginSuccess() {
    state = state.copyWith(showLogin: false);
    if (_pendingCheckout) {
      _pendingCheckout = false;
      state = state.copyWith(
        activeTab: AppTab.basket,
        basketStack: const [BasketListPage(), CheckoutPage()],
      );
    }
  }

  void dismissLogin() {
    _pendingCheckout = false;
    state = state.copyWith(showLogin: false);
  }

  // ── Logs ──────────────────────────────────────────────────────────────────

  void showLogs() => state = state.copyWith(showLogs: true);
  void dismissLogs() => state = state.copyWith(showLogs: false);

  // ── Logout ────────────────────────────────────────────────────────────────

  void onLogout() {
    _pendingCheckout = false;
    state = state.copyWith(basketStack: const [BasketListPage()]);
  }

  // ── Back ──────────────────────────────────────────────────────────────────

  /// Returns true if the notifier consumed the back event.
  bool onBack() {
    if (state.showLogs) {
      state = state.copyWith(showLogs: false);
      return true;
    }
    if (state.showLogin) {
      dismissLogin();
      return true;
    }
    switch (state.activeTab) {
      case AppTab.shop:
        if (state.shopStack.length > 1) {
          state = state.copyWith(
            shopStack: state.shopStack.sublist(0, state.shopStack.length - 1),
          );
          return true;
        }
      case AppTab.search:
        if (state.searchStack.length > 1) {
          state = state.copyWith(
            searchStack: state.searchStack.sublist(
              0,
              state.searchStack.length - 1,
            ),
          );
          return true;
        }
      case AppTab.basket:
        if (state.basketStack.length > 1) {
          state = state.copyWith(
            basketStack: state.basketStack.sublist(
              0,
              state.basketStack.length - 1,
            ),
          );
          return true;
        }
      case AppTab.account:
        break;
    }
    return false;
  }
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, NavigationState>(
      NavigationNotifier.new,
    );

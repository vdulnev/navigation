import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';
import '../../basket/screens/basket_screen.dart';
import '../../basket/screens/checkout_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../shop/screens/item_detail_screen.dart';
import '../../shop/screens/shop_screen.dart';
import '../../account/screens/account_screen.dart';

/// Tab scaffold that owns four independent per-tab Navigators.
///
/// Navigator 1 concepts demonstrated here:
///
/// • **IndexedStack** — all four tab widget trees (including their Navigator
///   stacks) stay mounted when the user switches tabs. State is never lost.
///
/// • **Per-tab Navigator with GlobalKey** — each tab has a
///   [GlobalKey<NavigatorState>] giving direct access to that tab's back-stack
///   without touching any other tab's stack.
///
/// • **Tap-to-root** — tapping the active tab icon calls
///   [Navigator.popUntil] on that tab's Navigator, returning to its first
///   (root) route.
///
/// • **PopScope + back-button delegation** — the Android back button first
///   tries to pop within the current tab's Navigator before allowing the
///   system to exit the app.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  /// One key per tab — direct handle to each tab's [NavigatorState].
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // 0 — Shop
    GlobalKey<NavigatorState>(), // 1 — Search
    GlobalKey<NavigatorState>(), // 2 — Basket
    GlobalKey<NavigatorState>(), // 3 — Account
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // Tapping the already-active tab pops back to its root route.
      _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) return;
    // Delegate the back press to the current tab's Navigator first.
    final nav = _navigatorKeys[_currentIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
    // If the tab's stack is at its root, we stay in the app (no system pop).
  }

  // ── Per-tab route factories ────────────────────────────────────────────────

  static Route<Object?> _shopRoutes(RouteSettings s) => switch (s.name) {
    AppRoutes.shopDetail => MaterialPageRoute<void>(
      settings: s,
      builder: (_) => const ItemDetailScreen(),
    ),
    _ => MaterialPageRoute<void>(builder: (_) => const ShopScreen()),
  };

  static Route<Object?> _searchRoutes(RouteSettings s) =>
      MaterialPageRoute<void>(builder: (_) => const SearchScreen());

  static Route<Object?> _basketRoutes(RouteSettings s) => switch (s.name) {
    AppRoutes.checkout => MaterialPageRoute<void>(
      builder: (_) => const CheckoutScreen(),
    ),
    _ => MaterialPageRoute<void>(builder: (_) => const BasketScreen()),
  };

  static Route<Object?> _accountRoutes(RouteSettings s) =>
      MaterialPageRoute<void>(builder: (_) => const AccountScreen());

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // We intercept every back event and handle it ourselves.
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Each Navigator widget is the root of one tab's back-stack.
            Navigator(
              key: _navigatorKeys[0],
              initialRoute: '/',
              onGenerateRoute: _shopRoutes,
            ),
            Navigator(
              key: _navigatorKeys[1],
              initialRoute: '/',
              onGenerateRoute: _searchRoutes,
            ),
            Navigator(
              key: _navigatorKeys[2],
              initialRoute: '/',
              onGenerateRoute: _basketRoutes,
            ),
            Navigator(
              key: _navigatorKeys[3],
              initialRoute: '/',
              onGenerateRoute: _accountRoutes,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined),
              activeIcon: Icon(Icons.shopping_basket),
              label: 'Basket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

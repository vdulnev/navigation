import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';
import '../../account/screens/account_screen.dart';
import '../../basket/screens/basket_screen.dart';
import '../../basket/screens/checkout_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../shop/screens/item_detail_screen.dart';
import '../../shop/screens/shop_screen.dart';

/// Rail scaffold that owns four independent per-section Navigators.
///
/// Navigator 1 concepts demonstrated here:
///
/// • **IndexedStack** — all four section widget trees (including their
///   Navigator stacks) stay mounted when the user switches sections. State is
///   never lost.
///
/// • **Per-section Navigator with GlobalKey** — each section has a
///   [GlobalKey<NavigatorState>] giving direct access to that section's
///   back-stack without touching any other section's stack.
///
/// • **Tap-to-root** — tapping the already-selected rail destination calls
///   [Navigator.popUntil] on that section's Navigator, returning to its first
///   (root) route.
///
/// • **PopScope + back-button delegation** — the Android back button first
///   tries to pop within the current section's Navigator before allowing the
///   system to exit the app.
///
/// • **NavigationRail vs BottomNavigationBar** — the Navigator architecture
///   (IndexedStack + GlobalKey Navigators) is identical to nav1_tabs. Only the
///   chrome widget changed: `NavigationRail` renders vertically on the left
///   instead of horizontally at the bottom. This shows that Navigator
///   structure is independent of the navigation chrome widget chosen.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  /// One key per section — direct handle to each section's [NavigatorState].
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // 0 — Shop
    GlobalKey<NavigatorState>(), // 1 — Search
    GlobalKey<NavigatorState>(), // 2 — Basket
    GlobalKey<NavigatorState>(), // 3 — Account
  ];

  void _onDestinationSelected(int index) {
    if (index == _currentIndex) {
      // Tapping the already-active destination pops back to its root route.
      _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) return;
    // Delegate the back press to the current section's Navigator first.
    final nav = _navigatorKeys[_currentIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
    // If the section's stack is at its root, we stay in the app (no system pop).
  }

  // ── Per-section route factories ────────────────────────────────────────────

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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // We intercept every back event and handle it ourselves.
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        body: Row(
          children: [
            // NavigationRail renders vertically on the left side.
            // The same IndexedStack + GlobalKey Navigator pattern from
            // nav1_tabs works unchanged — only the chrome widget differs.
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              // labelType: always shows labels below icons (no need to hover).
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: Text('Shop'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_basket_outlined),
                  selectedIcon: Icon(Icons.shopping_basket),
                  label: Text('Basket'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Account'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // The IndexedStack fills the remaining horizontal space.
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  // Each Navigator widget is the root of one section's back-stack.
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
            ),
          ],
        ),
      ),
    );
  }
}

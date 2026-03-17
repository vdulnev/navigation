import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/talker.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/navigation_provider.dart';
import '../../../router/navigation_state.dart';
import '../../../router/talker_navigator_observer.dart';
import '../../account/screens/account_screen.dart';
import '../../basket/screens/basket_screen.dart';
import '../../basket/screens/checkout_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../shop/screens/item_detail_screen.dart';
import '../../shop/screens/shop_screen.dart';

/// Persistent tab scaffold.
///
/// Navigator 2 concepts demonstrated:
///
/// * **Nested [Navigator]s**: each tab has its own [Navigator] with a
///   [GlobalKey]. Pages are rebuilt from [NavigationState] on every
///   [Consumer] rebuild — the [Navigator] diffs old vs new page list.
///
/// * **[IndexedStack]**: keeps all four tab Navigators alive in the widget
///   tree; only the active one is visible. Tab state (scroll position, etc.)
///   is preserved when switching tabs.
///
/// * **[TalkerNavigatorObserver] per tab**: each nested [Navigator] gets its
///   own observer with a distinct label ('shop', 'search', etc.) so Talker
///   logs show exactly which tab's navigator fired an event.
///
/// * **[PopScope]**: intercepts the Android back button. Tries to pop the
///   active tab's stack first via [NavigationNotifier.onBack]; if that
///   returns false the system back is allowed (exits the app).
class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  final _shopKey = GlobalKey<NavigatorState>();
  final _searchKey = GlobalKey<NavigatorState>();
  final _basketKey = GlobalKey<NavigatorState>();
  final _accountKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(navigationProvider);
    final nav = ref.read(navigationProvider.notifier);

    final basketCount = ref.watch(
      basketProvider.select((items) => items.fold(0, (s, i) => s + i.quantity)),
    );

    // ── Auth listener — reset basket stack on logout ───────────────────────
    ref.listen<bool>(authProvider, (_, isLoggedIn) {
      if (!isLoggedIn) nav.onLogout();
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => nav.onBack(),
      child: Scaffold(
        body: IndexedStack(
          index: state.activeTab.index,
          children: [
            _TabNavigator(
              navigatorKey: _shopKey,
              label: 'shop',
              pages: _shopPages(state),
            ),
            _TabNavigator(
              navigatorKey: _searchKey,
              label: 'search',
              pages: _searchPages(state),
            ),
            _TabNavigator(
              navigatorKey: _basketKey,
              label: 'basket',
              pages: _basketPages(state),
            ),
            _TabNavigator(
              navigatorKey: _accountKey,
              label: 'account',
              pages: _accountPages(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: state.activeTab.index,
          onTap: (i) => nav.setTab(AppTab.values[i]),
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.store),
              label: 'Shop',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: basketCount > 0,
                label: Text('$basketCount'),
                child: const Icon(Icons.shopping_basket_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: basketCount > 0,
                label: Text('$basketCount'),
                child: const Icon(Icons.shopping_basket),
              ),
              label: 'Basket',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  List<Page<dynamic>> _shopPages(NavigationState state) => [
    const MaterialPage(key: ValueKey('shop'), child: ShopScreen()),
    for (final page in state.shopStack)
      if (page case ShopDetailPage(:final product))
        MaterialPage(
          key: ValueKey('shop-detail-${product.id}'),
          child: ItemDetailScreen(product: product),
        ),
  ];

  List<Page<dynamic>> _searchPages(NavigationState state) => [
    const MaterialPage(key: ValueKey('search'), child: SearchScreen()),
    for (final page in state.searchStack)
      if (page case SearchDetailPage(:final product))
        MaterialPage(
          key: ValueKey('search-detail-${product.id}'),
          child: ItemDetailScreen(product: product),
        ),
  ];

  List<Page<dynamic>> _basketPages(NavigationState state) => [
    const MaterialPage(key: ValueKey('basket'), child: BasketScreen()),
    for (final page in state.basketStack)
      if (page is CheckoutPage)
        const MaterialPage(key: ValueKey('checkout'), child: CheckoutScreen()),
  ];

  List<Page<dynamic>> _accountPages() => [
    const MaterialPage(key: ValueKey('account'), child: AccountScreen()),
  ];
}

/// A [Navigator] widget for a single tab.
///
/// Navigator 2 concept: rebuilds its page list every time [pages] changes.
/// [onDidRemovePage] propagates platform-driven pops (iOS swipe-back) back to
/// [NavigationNotifier] so Riverpod state stays in sync with the visual stack.
class _TabNavigator extends ConsumerWidget {
  const _TabNavigator({
    required this.navigatorKey,
    required this.label,
    required this.pages,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final String label;
  final List<Page<dynamic>> pages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationProvider.notifier);
    return Navigator(
      key: navigatorKey,
      pages: pages,
      observers: [TalkerNavigatorObserver(talker, label: label)],
      onDidRemovePage: (_) => nav.onBack(),
    );
  }
}

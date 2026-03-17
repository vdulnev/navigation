import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_router.dart';

/// Persistent tab scaffold with [BottomNavigationBar].
///
/// Beamer concepts demonstrated:
///
/// • **Per-tab [BeamerDelegate]**: each tab has its own delegate provided via
///   Riverpod. Wrapping each in a [Beamer] widget gives it an independent
///   [Navigator] — pushing detail screens stays within the active tab's stack.
///
/// • **[IndexedStack]**: preserves every tab's widget tree and scroll state
///   when switching tabs — same behaviour as GoRouter's
///   `StatefulShellRoute.indexedStack`.
///
/// • **Active-tab pop on re-tap**: tapping the active tab icon calls
///   `delegate.beamBack()`, which pops to the delegate's previous location
///   (e.g. collapses detail → list). If already at root, beamBack is a no-op.
///
/// • **Logout stack reset**: `ref.listenManual(authProvider, …)` fires when
///   auth drops to false and resets the basket delegate to `/basket`, clearing
///   any in-progress checkout from the back-stack silently.
class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Reset the basket delegate's back-stack on logout so that any in-progress
    // checkout is gone before the user returns to the basket tab.
    ref.listenManual<bool>(authProvider, (_, isLoggedIn) {
      if (!isLoggedIn) {
        ref.read(basketDelegateProvider).beamToNamed(AppRoutes.basket);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopD = ref.watch(shopDelegateProvider);
    final searchD = ref.watch(searchDelegateProvider);
    final basketD = ref.watch(basketDelegateProvider);
    final accountD = ref.watch(accountDelegateProvider);

    final basketCount = ref.watch(
      basketProvider.select((items) => items.fold(0, (s, i) => s + i.quantity)),
    );

    final delegates = [shopD, searchD, basketD, accountD];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          Beamer(routerDelegate: shopD),
          Beamer(routerDelegate: searchD),
          Beamer(routerDelegate: basketD),
          Beamer(routerDelegate: accountD),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) {
          if (index == _index) {
            // Re-tapping the active tab pops to the delegate's root location.
            delegates[index].beamBack();
          }
          setState(() => _index = index);
        },
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
    );
  }
}

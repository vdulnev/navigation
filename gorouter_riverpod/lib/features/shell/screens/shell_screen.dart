import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_router.dart';

/// Persistent shell with [BottomNavigationBar].
///
/// GoRouter concepts demonstrated:
///
/// • **[StatefulShellRoute.indexedStack]**: each tab keeps its own navigator
///   and preserves scroll/back-stack state when switching tabs.
///
/// • **[StatefulNavigationShell.goBranch]**: switches the active branch;
///   passing `initialLocation: true` when re-tapping the active tab pops
///   to the branch root (same behaviour as nav1_tabs).
///
/// • **[basketNavigatorKey] reset on logout**: when auth drops to false,
///   `popUntil(isFirst)` resets the basket branch back-stack silently —
///   no tab switch, checkout is gone before the user returns to basket.
class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(authProvider, (_, isLoggedIn) {
      if (!isLoggedIn) {
        basketNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });

    final basketCount = ref.watch(
      basketProvider.select((items) => items.fold(0, (s, i) => s + i.quantity)),
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Re-tapping the active tab pops to the branch root.
          initialLocation: index == navigationShell.currentIndex,
        ),
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

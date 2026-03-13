import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/basket_provider.dart';
import '../../account/screens/account_screen.dart';
import '../../basket/screens/basket_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../shop/screens/shop_screen.dart';

/// Tab scaffold with [BottomNavigationBar] + [IndexedStack].
///
/// GetX + Riverpod concepts demonstrated:
///
/// • **IndexedStack** — all four section widget trees stay mounted when the
///   user switches tabs. Riverpod state (basket, search query) is preserved.
///
/// • **ConsumerStatefulWidget** — mixes Riverpod (watching basket count for
///   the badge) with local [setState] for the selected tab index.
///
/// • **No nested Navigators** — unlike nav1_tabs, there is only one GetX
///   navigator. Detail screens and login are pushed via [Get.toNamed], which
///   pushes above this shell (hiding the BottomNavigationBar). No
///   `rootNavigator: true` equivalent is needed.
///
/// • **Basket badge** — derived from [basketProvider] via Riverpod. The badge
///   updates reactively whenever items are added or removed anywhere in the app.
class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _currentIndex = 0;

  static const _sections = [
    ShopScreen(),
    SearchScreen(),
    BasketScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final basketCount = ref.watch(
      basketProvider.select((items) => items.fold(0, (s, i) => s + i.quantity)),
    );

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _sections),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
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

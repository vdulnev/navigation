import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/basket_controller.dart';
import '../../account/screens/account_screen.dart';
import '../../basket/screens/basket_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../shop/screens/shop_screen.dart';

/// Tab scaffold with [BottomNavigationBar] + [IndexedStack].
///
/// GetX concepts demonstrated:
///
/// • **IndexedStack** — all four sections stay mounted when the user switches
///   tabs. GetX controller state (basket, search query) is preserved.
///
/// • **Obx** — the basket badge count rebuilds reactively via
///   `Get.find<BasketController>().items`.
///
/// • **No nested Navigators** — detail screens and login are pushed via
///   [Get.toNamed], which pushes above this shell.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  static const _sections = [
    ShopScreen(),
    SearchScreen(),
    BasketScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final basket = Get.find<BasketController>();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _sections),
      bottomNavigationBar: Obx(() {
        final count = basket.itemCount;
        return BottomNavigationBar(
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
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.shopping_basket_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
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
        );
      }),
    );
  }
}

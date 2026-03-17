import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_router.dart';

/// Persistent shell with [BottomNavigationBar].
///
/// AutoRoute concepts demonstrated:
///
/// * **EmptyShellRoute**: each tab is declared as `EmptyShellRoute('Name')`
///   in the router config — AutoRoute creates a nested [AutoRouter] (and its
///   own [StackRouter]) for each tab automatically. No separate file needed.
///
/// * **AutoTabsRouter**: without explicit `routes`, reads tab routes from the
///   router config's children. `builder` receives `(context, child)` where
///   `child` is the active tab's content (rendered via [IndexedStack]).
///
/// * **context.tabsRouter**: extension on [BuildContext] that returns the
///   nearest [TabsRouter] — used to read [activeIndex] and switch tabs.
///
/// * **tabsRouter.stackRouterOfIndex(n)?.popUntilRoot()**: resets a specific
///   tab's back-stack without switching the active tab. Used here to pop
///   checkout when the user logs out.
///
/// * **_authGatedRoutes**: only tabs whose stack contains a known auth-gated
///   route are reset on logout — other tabs (Shop, Search) keep their state.
/// Route names that require authentication. On logout, any tab whose stack
/// contains one of these is popped to root; other tabs are left untouched.
const _authGatedRoutes = {CheckoutRoute.name};

@RoutePage(name: 'ShellRoute')
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final tabsRouter = context.tabsRouter;

            ref.listen<bool>(authProvider, (_, isLoggedIn) {
              if (!isLoggedIn) {
                for (var i = 0; i < tabsRouter.pageCount; i++) {
                  final stack = tabsRouter.stackRouterOfIndex(i);
                  if (stack != null &&
                      stack.stackData.any(
                        (r) => _authGatedRoutes.contains(r.name),
                      )) {
                    stack.popUntilRoot();
                  }
                }
              }
            });

            final basketCount = ref.watch(
              basketProvider.select(
                (items) => items.fold(0, (s, i) => s + i.quantity),
              ),
            );

            return Scaffold(
              body: child,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: tabsRouter.activeIndex,
                onTap: (index) {
                  if (index == tabsRouter.activeIndex) {
                    tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
                  } else {
                    tabsRouter.setActiveIndex(index);
                  }
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
          },
        );
      },
    );
  }
}

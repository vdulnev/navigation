import 'package:flutter/material.dart';

import '../features/auth/services/auth_service.dart';
import '../features/shop/services/basket_service.dart';
import '../router/app_routes.dart';
import 'nav_note_card.dart';

/// Shared [Drawer] widget included in every section screen.
///
/// Navigator 1 concepts demonstrated:
///
/// • **`pushNamedAndRemoveUntil` for section switching** — each drawer item
///   clears the entire back-stack (`(r) => false`) before pushing the target
///   section. This prevents Back from cycling through previously visited
///   sections; Back from a section root exits the app.
///
/// • **`Navigator.pop()` closes the drawer** — in Flutter's Navigator 1 model
///   the [Drawer] is pushed as an overlay route. Calling [Navigator.pop]
///   (captured *before* the pop fires to survive widget unmounting) dismisses
///   it, then the second call navigates.
///
/// • **Single Navigator — no `rootNavigator: true` needed** — unlike a
///   nested-navigator layout (e.g. nav1_tabs), `Navigator.of(context)` always
///   reaches the single root Navigator, so no special flag is required.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.activeRoute});

  /// Route name of the currently visible section screen.
  final String activeRoute;

  void _navigate(BuildContext context, String route) {
    // Capture the NavigatorState *before* pop() dismounts this widget.
    final nav = Navigator.of(context);
    nav.pop(); // Dismiss the drawer (it is a Navigator overlay route).
    nav.pushNamedAndRemoveUntil(route, (r) => false);
  }

  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    nav.pop(); // Close the drawer first.
    await AuthService.logout();
    BasketService.clear();
    nav.pushNamedAndRemoveUntil(AppRoutes.shop, (r) => false);
  }

  Widget _sectionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final active = route == activeRoute;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: active,
      selectedColor: Theme.of(context).colorScheme.primary,
      onTap: active
          ? () => Navigator.of(context)
                .pop() // already here — just close
          : () => _navigate(context, route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'Shop',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AuthService.isLoggedIn ? 'user@example.com' : 'Not signed in',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          _sectionTile(
            context,
            icon: Icons.storefront_outlined,
            label: 'Shop',
            route: AppRoutes.shop,
          ),
          _sectionTile(
            context,
            icon: Icons.search_outlined,
            label: 'Search',
            route: AppRoutes.search,
          ),
          _sectionTile(
            context,
            icon: Icons.shopping_basket_outlined,
            label: 'Basket',
            route: AppRoutes.basket,
          ),
          _sectionTile(
            context,
            icon: Icons.person_outline,
            label: 'Account',
            route: AppRoutes.account,
          ),
          if (AuthService.isLoggedIn) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () => _signOut(context),
            ),
          ],
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: NavNoteCard(
              title: 'Navigator 1: pushNamedAndRemoveUntil (drawer)',
              body:
                  'Each section clears the entire stack with predicate '
                  '(r) => false before pushing. Back from a section root '
                  'exits the app — sections do not stack on each other.',
            ),
          ),
        ],
      ),
    );
  }
}

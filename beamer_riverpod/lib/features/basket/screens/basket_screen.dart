import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/screens/login_screen.dart';

/// Basket section — requires login to view contents.
///
/// Beamer + Riverpod concepts demonstrated:
///
/// • **In-screen auth gate**: basket stays inside the shell so the bottom
///   navigation bar remains visible. The unauthenticated state is handled
///   here rather than by a BeamGuard, keeping the tab chrome visible.
///
/// • **BeamGuard on checkout only**: [basketDelegate] has a [BeamGuard]
///   that intercepts `/basket/checkout` and pushes login via the root
///   Navigator if the user is not logged in. BasketScreen itself is
///   always reachable so the tab bar stays present.
///
/// • **Riverpod watch**: `ref.watch(basketProvider)` rebuilds automatically
///   when items change — no setState needed after checkout.
class BasketScreen extends ConsumerWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Basket')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to view your basket',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    await Navigator.of(
                      context,
                      rootNavigator: true,
                    ).push<bool>(
                      MaterialPageRoute<bool>(
                        fullscreenDialog: true,
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                const NavNoteCard(
                  title: 'Beamer: in-screen auth gate',
                  body:
                      'Basket stays inside the shell so the bottom nav bar '
                      'remains visible. Unauthenticated state is handled '
                      'inline; BeamGuard only intercepts /basket/checkout.',
                ),
              ],
            ),
          ),
        ),
      );
    }

    final items = ref.watch(basketProvider);

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Basket')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text('Your basket is empty'),
            ],
          ),
        ),
      );
    }

    final notifier = ref.read(basketProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Basket')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: Text(
                      item.product.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(item.product.name),
                    subtitle: Text(
                      '${item.quantity} × \$${item.product.price.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => notifier.remove(item.product.id),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${notifier.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // BeamGuard on basketDelegate intercepts this push
                      // if the user is not logged in and presents LoginScreen
                      // via the root Navigator before allowing checkout.
                      onPressed: () => context.beamToNamed(AppRoutes.checkout),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';

/// Basket section — requires login to view contents.
///
/// GetX + Riverpod concepts demonstrated:
///
/// • **Riverpod watch**: `ref.watch(basketProvider)` makes this widget rebuild
///   whenever any item is added, removed, or the basket is cleared. No
///   explicit refresh or setState needed after checkout.
///
/// • **Auth gate via Riverpod**: `ref.watch(authProvider)` is a [bool] that
///   drives the sign-in wall. When [AuthNotifier.login] updates state, this
///   widget rebuilds automatically — no `setState()` after pop required.
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
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                const NavNoteCard(
                  title: 'Riverpod: reactive auth gate',
                  body:
                      'ref.watch(authProvider) rebuilds this widget when login '
                      'succeeds — no setState() or manual refresh. '
                      'Get.toNamed(login) navigates without a BuildContext.',
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
                      onPressed: () => Get.toNamed(AppRoutes.checkout),
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

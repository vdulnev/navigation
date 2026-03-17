import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/navigation_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Product detail screen — receives [Product] as a constructor argument.
///
/// Navigator 2 concept: this screen lives in either the shop or search tab's
/// nested [Navigator], depending on which stack it was pushed onto. The
/// [Product] is passed directly as a constructor arg (no URL encoding, no
/// GoRouterState.extra — the page list is built in Dart by [ShellScreen]).
///
/// Auth guard: if not logged in, [NavigationNotifier.showLogin] pushes the
/// login page onto the root navigator. On success, [authProvider] updates and
/// this screen rebuilds — the user can then add to basket without re-tapping.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Text(product.emoji, style: const TextStyle(fontSize: 96)),
          ),
          const SizedBox(height: 24),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(product.description),
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.shopping_basket_outlined),
            label: const Text('Add to Basket'),
            onPressed: () {
              if (!isLoggedIn) {
                ref.read(navigationProvider.notifier).showLogin();
                return;
              }
              ref.read(basketProvider.notifier).add(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} added to basket')),
              );
            },
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'Navigator 2: constructor arg + reactive auth',
            body:
                'Product is passed as a constructor argument — no URL encoding '
                'or state.extra needed. Auth guard calls showLogin() on the '
                'root Navigator; this screen reactively watches authProvider '
                'and rebuilds when login succeeds.',
          ),
        ],
      ),
    );
  }
}

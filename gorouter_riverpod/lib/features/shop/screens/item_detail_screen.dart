import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';

/// Product detail — receives [Product] via [GoRouterState.extra].
///
/// The active branch determines which tab's navigator this screen lives in:
/// `/shop/detail` → shop branch, `/search/detail` → search branch.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () async {
              if (!ref.read(authProvider)) {
                final loggedIn = await context.push<bool>(AppRoutes.login);
                if (loggedIn != true) return;
              }
              ref.read(basketProvider.notifier).add(product);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to basket')),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'GoRouter: extra + context.push return value',
            body:
                'Product passed via GoRouterState.extra — no path encoding. '
                'context.push<bool>(login) awaits the result; '
                'LoginScreen calls context.pop(true) on success.',
          ),
        ],
      ),
    );
  }
}

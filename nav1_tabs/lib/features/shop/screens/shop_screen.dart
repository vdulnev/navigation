import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../services/basket_service.dart';

/// Browse tab — shows all products in a grid.
///
/// Navigator 1 concepts demonstrated:
///
/// • **Push within tab Navigator** — tapping a product card calls
///   `Navigator.of(context).pushNamed(AppRoutes.shopDetail)`, which targets
///   the shop tab's own Navigator (the nearest ancestor), keeping the detail
///   screen inside the Shop tab's back-stack.
///
/// • **Auth guard with rootNavigator: true** — "Add to Basket" checks
///   [AuthService.isLoggedIn]. If the user is not authenticated it pushes
///   `/login` via `rootNavigator: true` so the login screen slides up *above*
///   the tab shell, not inside this tab's stack.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  Future<void> _addToBasket(BuildContext context, Product product) async {
    if (!AuthService.isLoggedIn) {
      // rootNavigator: true — targets the MaterialApp's Navigator so login
      // appears over the entire scaffold, above all tabs.
      final loggedIn =
          await Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.login)
              as bool?;
      if (loggedIn != true) return;
    }
    BasketService.add(product);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to basket'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: NavNoteCard(
                title: 'Navigator 1: nested Navigator + rootNavigator: true',
                body:
                    'Tap a card to push detail inside this tab\'s Navigator. '
                    '"Add to Basket" pushes /login via rootNavigator: true — '
                    'above the tab shell — when the user is not signed in.',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: kProducts.length,
              itemBuilder: (context, index) {
                final product = kProducts[index];
                return _ProductCard(
                  product: product,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.shopDetail, arguments: product),
                  onAddToBasket: () => _addToBasket(context, product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToBasket,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToBasket;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: onAddToBasket,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text(
                        'Add to Basket',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

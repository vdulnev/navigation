import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../services/basket_service.dart';

/// Shop section — product grid.
///
/// Navigator 1 concepts demonstrated:
///
/// • **`pushNamed` on the single root Navigator** — tapping a product card
///   pushes `/shop/detail` on the same Navigator that owns all section routes.
///   No nested navigators exist, so `Navigator.of(context)` always resolves
///   to the right Navigator.
///
/// • **Auth guard without `rootNavigator: true`** — the login push is a
///   plain `Navigator.of(context).pushNamed`. Compare with nav1_tabs where
///   the nested tab Navigators would have intercepted this call and
///   `rootNavigator: true` was required.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  Future<void> _addToBasket(BuildContext context, Product product) async {
    if (!AuthService.isLoggedIn) {
      final loggedIn =
          await Navigator.of(context).pushNamed(AppRoutes.login) as bool?;
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
      drawer: const AppDrawer(activeRoute: AppRoutes.shop),
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: NavNoteCard(
                title: 'Navigator 1: single Navigator, no rootNavigator needed',
                body:
                    'pushNamed(/shop/detail) and pushNamed(/login) both '
                    'target the single root Navigator directly. No nested '
                    'navigators, no rootNavigator: true required.',
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

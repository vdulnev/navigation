import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/nav_note_card.dart';

/// Shop section — product grid.
///
/// Beamer + Riverpod concepts demonstrated:
///
/// • **context.beamToNamed with data**: passes [Product] to the detail
///   screen via BeamState.data — no path encoding needed.
///
/// • **Root Navigator modal push with return value**: auth guard uses
///   `Navigator.of(context, rootNavigator: true).pushNamed<bool>(login)`.
///   The future resolves when [LoginScreen] calls `Navigator.of(context).pop(true)`.
///
/// • **Riverpod read**: basket mutation and auth check via `ref.read`.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  Future<void> _addToBasket(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    if (!ref.read(authProvider)) {
      final loggedIn = await Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamed<bool>(AppRoutes.login);
      if (loggedIn != true) return;
    }
    ref.read(basketProvider.notifier).add(product);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to basket'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: NavNoteCard(
                title: 'Beamer: beamToNamed + data',
                body:
                    'context.beamToNamed(shopDetail, data: product) — no path '
                    'param. Auth guard: rootNavigator.pushNamed<bool>(login) '
                    'returns value from Navigator.of(context).pop(true).',
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
                  onTap: () =>
                      context.beamToNamed(AppRoutes.shopDetail, data: product),
                  onAddToBasket: () => _addToBasket(context, ref, product),
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

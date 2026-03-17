import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/navigation_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Shop section — product grid.
///
/// Navigator 2 concept: tapping a product calls
/// [NavigationNotifier.pushShopDetail], which appends a [ShopDetailPage] to
/// [NavigationState.shopStack]. [ShellScreen] rebuilds [_shopPages] and the
/// nested [Navigator] diffs old vs new page list to push [ItemDetailScreen].
///
/// Auth guard: instead of awaiting a push and reading a return value, tapping
/// "Add to Basket" while unauthenticated calls [NavigationNotifier.showLogin].
/// The login page appears; on success, [NavigationNotifier.onLoginSuccess]
/// dismisses it. The screen then reacts to [authProvider] changing.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  void _addToBasket(WidgetRef ref, Product product, BuildContext context) {
    if (!ref.read(authProvider)) {
      ref.read(navigationProvider.notifier).showLogin();
      return;
    }
    ref.read(basketProvider.notifier).add(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to basket'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: NavNoteCard(
                title: 'Navigator 2: page-based navigation',
                body:
                    'Tapping a product calls navigationNotifier.pushShopDetail(). '
                    'ShellScreen rebuilds _shopPages() and the nested Navigator '
                    'diffs the old vs new page list to push ItemDetailScreen.',
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
                  onTap: () => nav.pushShopDetail(product),
                  onAddToBasket: () => _addToBasket(ref, product, context),
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

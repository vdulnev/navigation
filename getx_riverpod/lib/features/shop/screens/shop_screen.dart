import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';

/// Shop section — product grid.
///
/// GetX + Riverpod concepts demonstrated:
///
/// • **GetX navigation**: `Get.toNamed(AppRoutes.shopDetail, arguments: product)`
///   pushes above the shell without a BuildContext. No nested Navigator needed.
///
/// • **GetX auth guard**: `await Get.toNamed<bool>(AppRoutes.login)` returns
///   the value passed to `Get.back(result: true)` in LoginScreen.
///
/// • **Riverpod reads**: basket mutation via `ref.read(basketProvider.notifier)`
///   and auth check via `ref.read(authProvider)`.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  Future<void> _addToBasket(WidgetRef ref, Product product) async {
    if (!ref.read(authProvider)) {
      final loggedIn = await Get.toNamed(AppRoutes.login);
      if (loggedIn != true) return;
    }
    ref.read(basketProvider.notifier).add(product);
    Get.snackbar(
      'Added',
      '${product.name} added to basket',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
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
                title: 'GetX navigation + Riverpod state',
                body:
                    'Get.toNamed(shopDetail, arguments: product) — no context '
                    'needed. Auth guard: await Get.toNamed(login) returns bool '
                    'from Get.back(result: true). Basket via Riverpod notifier.',
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
                      Get.toNamed(AppRoutes.shopDetail, arguments: product),
                  onAddToBasket: () => _addToBasket(ref, product),
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

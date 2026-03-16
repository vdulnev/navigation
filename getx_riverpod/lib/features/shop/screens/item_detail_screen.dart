import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../models/product.dart';
import '../../../providers/basket_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Product detail — pushed via [Get.toNamed] with a [Product] argument.
///
/// [Get.arguments] reads the product passed by the caller. All navigation
/// (auth guard, snackbar) is delegated to [BasketNotifier.addWithAuthGuard].
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = Get.arguments as Product;
    final basket = ref.read(basketProvider.notifier);

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
            onPressed: () => basket.addWithAuthGuard(product),
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'GetX arguments + navigation in provider',
            body:
                'Product read via Get.arguments — no ModalRoute needed. '
                'Auth guard, basket add, and snackbar all live in '
                'basketProvider.notifier.addWithAuthGuard.',
          ),
        ],
      ),
    );
  }
}

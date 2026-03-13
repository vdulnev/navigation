import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';

/// Product detail — pushed via [Get.toNamed] with a [Product] argument.
///
/// GetX + Riverpod concepts demonstrated:
///
/// • **GetX arguments**: `Get.arguments as Product` reads the value passed to
///   `Get.toNamed(AppRoutes.shopDetail, arguments: product)`. Simpler than
///   `ModalRoute.of(context).settings.arguments`.
///
/// • **GetX back**: `Get.back()` pops to the shell. No BuildContext needed.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = Get.arguments as Product;

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
                final loggedIn = await Get.toNamed(AppRoutes.login);
                if (loggedIn != true) return;
              }
              ref.read(basketProvider.notifier).add(product);
              Get.snackbar(
                'Added',
                '${product.name} added to basket',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'GetX: Get.arguments + Get.toNamed return value',
            body:
                'Product read via Get.arguments — no ModalRoute needed. '
                'Auth guard uses await Get.toNamed<bool>(login); '
                'LoginScreen calls Get.back(result: true) on success.',
          ),
        ],
      ),
    );
  }
}

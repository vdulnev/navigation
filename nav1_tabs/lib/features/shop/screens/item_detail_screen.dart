import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../services/basket_service.dart';

/// Product detail screen — reachable from both the Shop and Search tabs.
///
/// Navigator 1 concepts demonstrated:
///
/// • **ModalRoute.settings.arguments** — the [Product] is passed via
///   `pushNamed(AppRoutes.shopDetail, arguments: product)` and read with
///   `ModalRoute.of(context)!.settings.arguments`.
///
/// • Runs inside the calling tab's own Navigator, so the back button
///   returns to that tab's previous screen (shop grid or search results).
///
/// • Auth guard uses `rootNavigator: true` (same pattern as [ShopScreen]).
class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

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
              if (!AuthService.isLoggedIn) {
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
                SnackBar(content: Text('${product.name} added to basket')),
              );
            },
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'Navigator 1: arguments + rootNavigator: true',
            body:
                'Product is passed via pushNamed arguments and read with '
                'ModalRoute.of(context).settings.arguments. '
                'Login is presented via rootNavigator: true — above the tabs.',
          ),
        ],
      ),
    );
  }
}

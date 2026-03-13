import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../services/basket_service.dart';

/// Product detail — pushed on top of Shop or Search via [AppRoutes.shopDetail].
///
/// Navigator 1 concepts demonstrated:
///
/// • **No [NavigationRail]** — detail screens are nested within a section. The
///   rail belongs only to the shell. The AppBar shows a Back arrow instead.
///
/// • **`ModalRoute.settings.arguments`** — the [Product] is passed via
///   `pushNamed(AppRoutes.shopDetail, arguments: product)` and read here.
///
/// • **`rootNavigator: true` auth guard** — login must escape the section's
///   nested Navigator to slide above the full rail shell.
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
            title: 'Navigator 1: arguments + rootNavigator auth guard',
            body:
                'Product passed via pushNamed arguments, read with '
                'ModalRoute.of(context).settings.arguments. '
                'Login uses rootNavigator: true to push above the rail shell.',
          ),
        ],
      ),
    );
  }
}

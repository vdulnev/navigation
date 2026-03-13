import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../../shop/services/basket_service.dart';

/// Basket tab — requires login to view contents and proceed to checkout.
///
/// Navigator 1 concepts demonstrated:
///
/// • **Auth gate on a tab screen** — if the user is not signed in the screen
///   shows a prompt and pushes `/login` via `rootNavigator: true` when tapped.
///   When the Future resolves, `setState()` rebuilds the screen to reveal the
///   basket contents — no state management library needed.
///
/// • **Push within tab Navigator** — the Checkout button calls
///   `Navigator.of(context).pushNamed(AppRoutes.checkout)` which targets this
///   tab's own Navigator, keeping checkout inside the Basket back-stack.
class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  Future<void> _signIn() async {
    final loggedIn =
        await Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(AppRoutes.login)
            as bool?;
    if (loggedIn == true && mounted) {
      // Rebuild to show basket contents now that the user is authenticated.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Basket')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to view your basket',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _signIn, child: const Text('Sign In')),
                const SizedBox(height: 24),
                const NavNoteCard(
                  title: 'Navigator 1: auth gate + setState after pop',
                  body:
                      'Sign In pushes /login via rootNavigator: true. '
                      'When the modal closes, setState() rebuilds this screen '
                      'to show the basket — no state management needed.',
                ),
              ],
            ),
          ),
        ),
      );
    }

    final items = BasketService.items;

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Basket')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text('Your basket is empty'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Basket')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: Text(
                      item.product.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(item.product.name),
                    subtitle: Text(
                      '${item.quantity} × \$${item.product.price.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        BasketService.remove(item.product.id);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${BasketService.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // pushNamed on the tab's own Navigator — checkout stays
                      // inside the Basket tab's back-stack.
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.checkout),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

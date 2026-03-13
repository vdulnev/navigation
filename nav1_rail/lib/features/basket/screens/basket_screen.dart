import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../../shop/services/basket_service.dart';

/// Basket section — requires login to view contents.
///
/// Navigator 1 concepts demonstrated:
///
/// • **Auth gate with `rootNavigator: true`** — the Sign In button pushes
///   `/login` above the entire rail shell. `setState()` rebuilds this screen
///   when the login route pops.
///
/// • **`pushNamed` within section** — the Checkout button pushes
///   `/checkout` inside *this section's* Navigator; back returns here.
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
    if (loggedIn == true && mounted) setState(() {});
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
                  title: 'Navigator 1: auth gate with rootNavigator: true',
                  body:
                      'pushNamed(/login) uses rootNavigator: true to push the '
                      'login screen above the rail shell. setState() rebuilds '
                      'this section when login pops.',
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

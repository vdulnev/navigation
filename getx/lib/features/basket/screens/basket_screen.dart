import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/basket_controller.dart';
import '../../../widgets/nav_note_card.dart';

/// Basket section — requires login to view contents.
///
/// GetX concepts demonstrated:
///
/// • **Obx**: `auth.isLoggedIn` and `basket.items` are both `.obs` — the
///   entire body rebuilds when either changes. No setState or manual refresh.
///
/// • **Auth gate**: when [AuthController.login] sets `isLoggedIn.value = true`,
///   this widget rebuilds automatically — no callback after pop required.
class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final basket = Get.find<BasketController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Basket')),
      body: Obx(() {
        if (!auth.isLoggedIn.value) {
          return _buildSignIn(auth);
        }
        if (basket.items.isEmpty) {
          return _buildEmpty();
        }
        return _buildBasket(context, basket);
      }),
    );
  }

  Widget _buildSignIn(AuthController auth) {
    return Center(
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
            FilledButton(
              onPressed: auth.navigateToLogin,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 24),
            const NavNoteCard(
              title: 'GetX: reactive auth gate',
              body:
                  'Obx reads auth.isLoggedIn — rebuilds this widget '
                  'when login succeeds. No setState() or manual '
                  'refresh needed.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Your basket is empty'),
        ],
      ),
    );
  }

  Widget _buildBasket(BuildContext context, BasketController basket) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: basket.items.length,
            itemBuilder: (context, index) {
              final item = basket.items[index];
              return Card(
                child: ListTile(
                  leading: Text(
                    item.product.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(item.product.name),
                  subtitle: Text(
                    '${item.quantity} '
                    '× \$${item.product.price.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => basket.remove(item.product.id),
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
                      '\$${basket.total.toStringAsFixed(2)}',
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
                    onPressed: basket.navigateToCheckout,
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

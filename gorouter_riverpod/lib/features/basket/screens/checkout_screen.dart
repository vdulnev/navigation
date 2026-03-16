import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/basket_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Checkout screen — pushed via `context.push(AppRoutes.checkout)`.
///
/// GoRouter + Riverpod concepts demonstrated:
///
/// • **context.pop**: pops this route, returning to BasketScreen.
///
/// • **Riverpod mutation**: `basketProvider.notifier.clear()` updates state;
///   BasketScreen watches the same provider and switches to its empty state
///   automatically — no explicit refresh or navigator.pop with result needed.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _placed = false;

  void _placeOrder() {
    ref.read(basketProvider.notifier).clear();
    setState(() => _placed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_placed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Placed')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✅', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Your order has been placed!',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: context.pop,
                child: const Text('Back to Basket'),
              ),
            ],
          ),
        ),
      );
    }

    final items = ref.watch(basketProvider);
    final notifier = ref.read(basketProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => ListTile(
              leading: Text(
                item.product.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(item.product.name),
              subtitle: Text('Qty: ${item.quantity}'),
              trailing: Text(
                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '\$${notifier.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _placeOrder,
            child: const Text('Place Order'),
          ),
          const SizedBox(height: 16),
          const NavNoteCard(
            title: 'GoRouter: ref.listen pops on logout',
            body:
                'ref.listen(authProvider) fires before GoRouter rebuilds. '
                'When auth drops to false, context.go(basket) navigates '
                'declaratively — the router redirect only evaluates the active '
                'tab\'s route so this handles the offstage-branch case.',
          ),
        ],
      ),
    );
  }
}

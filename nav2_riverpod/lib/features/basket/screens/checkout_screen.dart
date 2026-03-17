import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/basket_provider.dart';
import '../../../router/navigation_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Checkout screen — pushed via [NavigationNotifier.pushCheckout].
///
/// Navigator 2 concept: this screen is in the basket tab's nested [Navigator]
/// stack ([NavigationState.basketStack] contains [CheckoutPage]). Calling
/// [NavigationNotifier.onBack] removes [CheckoutPage] from the stack; the
/// basket Navigator diffs the page list and pops this route automatically.
///
/// After placing an order, [BasketNotifier.clear] updates [basketProvider];
/// [BasketScreen] watches the same provider and switches to its empty state
/// automatically — no explicit navigator pop with a return value needed.
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
                onPressed: () => ref.read(navigationProvider.notifier).onBack(),
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
            title: 'Navigator 2: onBack() pops via state',
            body:
                'onBack() removes CheckoutPage from basketStack. The basket '
                'Navigator diffs the page list and pops this route — no '
                'context.pop() needed. basketProvider.clear() causes '
                'BasketScreen to rebuild into its empty state automatically.',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/nav_note_card.dart';
import '../../shop/services/basket_service.dart';

/// Checkout screen — pushed inside the Basket tab's Navigator.
///
/// Navigator 1 concepts demonstrated:
///
/// • Pushed via `Navigator.of(context).pushNamed(AppRoutes.checkout)` from
///   [BasketScreen], so it lives inside the Basket tab's back-stack.
///   The back button returns to the basket without affecting any other tab.
///
/// • After placing the order `Navigator.of(context).pop()` returns to
///   [BasketScreen], which then shows the empty-basket state.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _placed = false;

  void _placeOrder() {
    BasketService.clear();
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Basket'),
              ),
            ],
          ),
        ),
      );
    }

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
          ...BasketService.items.map(
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
              '\$${BasketService.total.toStringAsFixed(2)}',
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
            title: 'Navigator 1: push within tab Navigator',
            body:
                'Checkout is pushed via the basket tab\'s own Navigator. '
                'Back returns to BasketScreen without touching any other '
                'tab\'s navigation stack.',
          ),
        ],
      ),
    );
  }
}

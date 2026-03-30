import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/basket_controller.dart';
import '../../../widgets/nav_note_card.dart';

/// Checkout screen — pushed via [Get.toNamed] from BasketScreen.
///
/// GetX concepts demonstrated:
///
/// • **Get.back()** pops to BasketScreen. No BuildContext needed.
///
/// • **basket.clear()** mutates the `.obs` list; BasketScreen's `Obx`
///   rebuilds to show the empty state automatically when this screen pops.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _placed = false;

  void _placeOrder() {
    Get.find<BasketController>().clear();
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
                onPressed: Get.find<BasketController>().navigateBack,
                child: const Text('Back to Basket'),
              ),
            ],
          ),
        ),
      );
    }

    final basket = Get.find<BasketController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...basket.items.map(
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
                '\$${basket.total.toStringAsFixed(2)}',
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
              title: 'GetX: navigation + reactive state',
              body:
                  'Get.back() pops to BasketScreen without BuildContext. '
                  'basket.clear() updates the .obs list; BasketScreen '
                  'rebuilds reactively — no explicit refresh.',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/basket_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../models/product.dart';
import '../../../widgets/nav_note_card.dart';

/// Search section — live filter across the product catalogue.
///
/// Navigation delegated to [BasketController]:
/// • [BasketController.navigateToDetail] — tap a result
/// • [BasketController.addWithAuthGuard] — add to basket with auth gate
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final search = Get.find<ProductSearchController>();
    final basket = Get.find<BasketController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: 'Search products…',
              leading: const Icon(Icons.search),
              onChanged: (q) => search.query.value = q,
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final query = search.query.value;
              final results = search.results;
              return _buildResults(context, basket, query, results);
            }),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: NavNoteCard(
              title: 'GetX: reactive computed getter',
              body:
                  'ProductSearchController.results is a getter that reads '
                  'query.value. Obx detects the dependency and rebuilds '
                  'automatically — no explicit stream subscription.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    BasketController basket,
    String query,
    List<Product> results,
  ) {
    if (query.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    if (results.isEmpty) {
      return const Center(child: Text('No results found'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Text(product.emoji, style: const TextStyle(fontSize: 28)),
          title: Text(product.name),
          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'Add to basket',
            onPressed: () => basket.addWithAuthGuard(product),
          ),
          onTap: () => basket.navigateToDetail(product),
        );
      },
    );
  }
}

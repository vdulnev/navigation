import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../../shop/screens/item_detail_screen.dart';
import '../../shop/services/basket_service.dart';

/// Search tab — filters the product catalogue by name or description.
///
/// Navigator 1 concepts demonstrated:
///
/// • **Push within the Search tab's Navigator** — tapping a result pushes
///   [ItemDetailScreen] inside the Search tab's own Navigator stack. The back
///   button returns to the search results, not to the Shop tab.
///
/// • Auth guard uses `rootNavigator: true` (same pattern as [ShopScreen]).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Product> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    final q = query.toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? []
          : kProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(q) ||
                      p.description.toLowerCase().contains(q),
                )
                .toList();
    });
  }

  Future<void> _addToBasket(Product product) async {
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
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.name} added to basket')));
  }

  void _openDetail(Product product) {
    // Navigator.of(context) resolves to the Search tab's own Navigator —
    // detail opens inside the Search tab, not the Shop tab.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: AppRoutes.shopDetail, arguments: product),
        builder: (_) => const ItemDetailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _controller,
              hintText: 'Search products…',
              leading: const Icon(Icons.search),
              onChanged: _onChanged,
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(child: _buildResults()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: NavNoteCard(
              title: 'Navigator 1: tab-local Navigator',
              body:
                  'Results open ItemDetailScreen inside this tab\'s own '
                  'Navigator — back returns to search, not to Shop.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_controller.text.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No results found'));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final product = _results[index];
        return ListTile(
          leading: Text(product.emoji, style: const TextStyle(fontSize: 28)),
          title: Text(product.name),
          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'Add to basket',
            onPressed: () => _addToBasket(product),
          ),
          onTap: () => _openDetail(product),
        );
      },
    );
  }
}

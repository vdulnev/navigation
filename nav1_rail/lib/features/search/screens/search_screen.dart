import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../../shop/screens/item_detail_screen.dart';
import '../../shop/services/basket_service.dart';

/// Search section — live filter across the product catalogue.
///
/// Navigator 1 concepts demonstrated:
///
/// • **`push` within the section Navigator** — tapping a result pushes
///   [ItemDetailScreen] on *this section's* Navigator. Back returns to Search
///   without affecting any other section's stack.
///
/// • **`rootNavigator: true` auth guard** — same pattern as Shop: login must
///   escape the nested Navigator to appear above the entire rail shell.
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: NavNoteCard(
              title: 'Navigator 1: per-section back-stack',
              body:
                  'Detail opens on the Search section\'s own Navigator — back '
                  'returns to Search without resetting the Shop or Basket '
                  'section stacks. Each section\'s history is independent.',
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

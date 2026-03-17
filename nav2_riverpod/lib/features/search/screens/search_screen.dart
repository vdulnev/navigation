import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../providers/search_provider.dart';
import '../../../router/navigation_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Search section — live filter across the product catalogue.
///
/// Navigator 2 concept: tapping a result calls
/// [NavigationNotifier.pushSearchDetail], which appends a [SearchDetailPage]
/// to [NavigationState.searchStack]. The search tab's nested [Navigator]
/// diffs its page list and pushes [ItemDetailScreen] within the search branch
/// — the search tab stays active and the back stack is preserved.
///
/// Riverpod: [searchResultsProvider] derives from [searchQueryProvider].
/// Writing to one provider and reading the other keeps the widget stateless.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: 'Search products…',
              leading: const Icon(Icons.search),
              onChanged: (q) => ref.read(searchQueryProvider.notifier).set(q),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(child: _buildResults(context, ref, query, results)),
          const Padding(
            padding: EdgeInsets.all(16),
            child: NavNoteCard(
              title: 'Riverpod: derived Provider + per-tab back-stack',
              body:
                  'searchResultsProvider recomputes when searchQueryProvider '
                  'changes. pushSearchDetail() appends to searchStack; the '
                  'search Navigator diffs the page list — detail stays within '
                  'the search tab and the back-stack is preserved.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    WidgetRef ref,
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
            onPressed: () {
              if (!ref.read(authProvider)) {
                ref.read(navigationProvider.notifier).showLogin();
                return;
              }
              ref.read(basketProvider.notifier).add(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} added to basket')),
              );
            },
          ),
          onTap: () =>
              ref.read(navigationProvider.notifier).pushSearchDetail(product),
        );
      },
    );
  }
}

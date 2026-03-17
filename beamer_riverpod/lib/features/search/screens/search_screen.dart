import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../providers/search_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/nav_note_card.dart';

/// Search section — live filter across the product catalogue.
///
/// Beamer + Riverpod concepts demonstrated:
///
/// • **Derived provider**: [searchResultsProvider] reacts to
///   [searchQueryProvider]. The widget writes one and reads the other.
///
/// • **Per-tab navigation**: `context.beamToNamed(searchDetail, data: product)`
///   pushes within the search delegate's navigator, keeping the search tab
///   active and its back-stack intact.
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
              title: 'Riverpod: derived Provider + per-tab navigation',
              body:
                  'searchResultsProvider recomputes when searchQueryProvider '
                  'changes. beamToNamed(searchDetail) keeps detail within '
                  'the search delegate — back-stack is preserved per tab.',
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
            onPressed: () async {
              if (!ref.read(authProvider)) {
                final loggedIn = await Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed<bool>(AppRoutes.login);
                if (loggedIn != true) return;
              }
              ref.read(basketProvider.notifier).add(product);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to basket')),
                );
              }
            },
          ),
          onTap: () =>
              context.beamToNamed(AppRoutes.searchDetail, data: product),
        );
      },
    );
  }
}

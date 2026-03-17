import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

/// Derived provider — recomputes automatically when [searchQueryProvider]
/// changes. The widget reads this and never manages filter state itself.
final searchResultsProvider = Provider<List<Product>>((ref) {
  final q = ref.watch(searchQueryProvider).toLowerCase();
  if (q.isEmpty) return [];
  return kProducts
      .where(
        (p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q),
      )
      .toList();
});

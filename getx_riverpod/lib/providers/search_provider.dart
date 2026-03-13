import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

/// The current search query string.
///
/// Riverpod 3 has no StateProvider — a simple [Notifier<String>] is used
/// instead. The search screen calls [SearchQueryNotifier.set] on every
/// keystroke; [searchResultsProvider] reacts automatically.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

/// Derived provider — filters [kProducts] whenever [searchQueryProvider]
/// changes. No imperative filtering logic needed in the widget.
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

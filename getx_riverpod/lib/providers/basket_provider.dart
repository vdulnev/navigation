import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

class BasketItem {
  BasketItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  BasketItem copyWith({int? quantity}) =>
      BasketItem(product: product, quantity: quantity ?? this.quantity);
}

/// Riverpod state for the shopping basket.
///
/// An immutable list of [BasketItem]s managed by [BasketNotifier]. Any widget
/// that reads this provider rebuilds whenever items are added, removed, or
/// cleared — without any explicit setState() or stream subscriptions.
final basketProvider = NotifierProvider<BasketNotifier, List<BasketItem>>(
  BasketNotifier.new,
);

class BasketNotifier extends Notifier<List<BasketItem>> {
  @override
  List<BasketItem> build() => [];

  void add(Product product) {
    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, BasketItem(product: product)];
    }
  }

  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void clear() => state = [];

  int get itemCount => state.fold(0, (s, i) => s + i.quantity);

  double get total => state.fold(0, (s, i) => s + i.product.price * i.quantity);
}

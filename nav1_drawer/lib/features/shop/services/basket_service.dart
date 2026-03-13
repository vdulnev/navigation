import '../../../models/product.dart';

class BasketItem {
  BasketItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;
}

/// In-memory basket — no persistence, reset on app restart.
class BasketService {
  static final List<BasketItem> _items = [];

  static List<BasketItem> get items => List.unmodifiable(_items);

  static int get itemCount => _items.fold(0, (s, i) => s + i.quantity);

  static double get total =>
      _items.fold(0, (s, i) => s + i.product.price * i.quantity);

  static void add(Product product) {
    final existing = _items
        .where((i) => i.product.id == product.id)
        .firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _items.add(BasketItem(product: product));
    }
  }

  static void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
  }

  static void clear() => _items.clear();
}

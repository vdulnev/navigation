import 'package:get/get.dart';

import '../models/product.dart';
import '../router/app_routes.dart';
import 'auth_controller.dart';

class BasketItem {
  BasketItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  BasketItem copyWith({int? quantity}) =>
      BasketItem(product: product, quantity: quantity ?? this.quantity);
}

/// GetX controller for the shopping basket.
///
/// [items] is an `.obs` list — `Obx` widgets that read it rebuild whenever
/// items are added, removed, or cleared. Replacing the entire list (rather
/// than mutating in place) ensures GetX detects the change.
class BasketController extends GetxController {
  final items = <BasketItem>[].obs;

  void add(Product product) {
    final index = items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(BasketItem(product: product));
    }
  }

  void remove(String productId) {
    items.removeWhere((i) => i.product.id == productId);
  }

  void clear() => items.clear();

  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  double get total =>
      items.fold(0.0, (s, i) => s + i.product.price * i.quantity);

  /// Auth-guards, adds [product], then shows a confirmation snackbar.
  Future<void> addWithAuthGuard(Product product) async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn.value) {
      final loggedIn = await Get.toNamed(AppRoutes.login);
      if (loggedIn != true) return;
    }
    add(product);
    Get.snackbar(
      'Added',
      '${product.name} added to basket',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToDetail(Product product) =>
      Get.toNamed(AppRoutes.shopDetail, arguments: product);

  void navigateToCheckout() => Get.toNamed(AppRoutes.checkout);

  void navigateBack() => Get.back();
}

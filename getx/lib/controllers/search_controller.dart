import 'package:get/get.dart';

import '../models/product.dart';

/// GetX controller for product search.
///
/// [query] is an `.obs` string updated on every keystroke. [results] is a
/// computed getter — `Obx` widgets that call it rebuild whenever [query]
/// changes because they transitively read [query.value].
class ProductSearchController extends GetxController {
  final query = ''.obs;

  List<Product> get results {
    final q = query.value.toLowerCase();
    if (q.isEmpty) return [];
    return kProducts
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/basket_controller.dart';
import 'controllers/login_form_controller.dart';
import 'controllers/search_controller.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/basket/screens/checkout_screen.dart';
import 'features/shell/screens/shell_screen.dart';
import 'features/shop/screens/item_detail_screen.dart';
import 'router/app_routes.dart';

/// Root widget.
///
/// [GetMaterialApp] owns the global navigator. All controllers are registered
/// via [Get.put] with permanent bindings so they survive route changes.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controllers once, permanently.
    Get.put(AuthController(), permanent: true);
    Get.put(BasketController(), permanent: true);
    Get.put(ProductSearchController(), permanent: true);
    Get.put(LoginFormController(), permanent: true);

    return GetMaterialApp(
      title: 'Shop — GetX Only',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: AppRoutes.shell,
      getPages: [
        GetPage(name: AppRoutes.shell, page: () => const ShellScreen()),
        GetPage(
          name: AppRoutes.shopDetail,
          page: () => const ItemDetailScreen(),
        ),
        GetPage(name: AppRoutes.checkout, page: () => const CheckoutScreen()),
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
          transition: Transition.downToUp,
        ),
      ],
    );
  }
}

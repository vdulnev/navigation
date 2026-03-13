import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/basket/screens/checkout_screen.dart';
import 'features/shell/screens/shell_screen.dart';
import 'features/shop/screens/item_detail_screen.dart';
import 'router/app_routes.dart';

/// Root widget.
///
/// [GetMaterialApp] replaces [MaterialApp] and registers a global
/// [NavigatorKey] so that [Get.toNamed], [Get.back], and friends work without
/// a [BuildContext]. All routes are declared in [getPages].
///
/// [ProviderScope] is the Riverpod ancestor — it is placed in [main.dart]
/// above this widget so that GetX and Riverpod are independent of each other.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shop — GetX + Riverpod',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: AppRoutes.shell,
      getPages: [
        GetPage(name: AppRoutes.shell, page: () => const ShellScreen()),
        GetPage(
          name: AppRoutes.shopDetail,
          page: () => const ItemDetailScreen(),
        ),
        GetPage(name: AppRoutes.checkout, page: () => const CheckoutScreen()),
        // Login slides up from the bottom, matching the fullscreenDialog
        // behaviour from the Navigator 1 examples.
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
          transition: Transition.downToUp,
        ),

        // Basket and Account are sections inside ShellScreen's IndexedStack,
        // not top-level GetX routes — they are never pushed directly.
      ],
    );
  }
}

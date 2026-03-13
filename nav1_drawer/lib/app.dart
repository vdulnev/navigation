import 'package:flutter/material.dart';

import 'features/account/screens/account_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/basket/screens/basket_screen.dart';
import 'features/basket/screens/checkout_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/shop/screens/item_detail_screen.dart';
import 'features/shop/screens/shop_screen.dart';
import 'router/app_routes.dart';

/// Root widget — owns the **single** [MaterialApp] Navigator.
///
/// All routes, including section routes and detail routes, are registered
/// here in one flat route table. There are no nested Navigator widgets.
///
/// Compare with nav1_tabs where the ShellScreen contained four independent
/// nested Navigators and the root Navigator only owned `/` and `/login`.
/// Here every route lives in the same Navigator, which is why
/// `rootNavigator: true` is never needed anywhere in this app.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop — Navigator 1 Drawer',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      initialRoute: AppRoutes.shop,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<Object?> _onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.shop => const ShopScreen(),
      AppRoutes.search => const SearchScreen(),
      AppRoutes.basket => const BasketScreen(),
      AppRoutes.account => const AccountScreen(),
      AppRoutes.shopDetail => const ItemDetailScreen(),
      AppRoutes.checkout => const CheckoutScreen(),
      AppRoutes.login => const LoginScreen(),
      _ => const ShopScreen(),
    };

    return MaterialPageRoute<Object?>(
      settings: settings, // Forward settings so arguments are accessible.
      // fullscreenDialog gives the login screen its "slide up" animation.
      fullscreenDialog: settings.name == AppRoutes.login,
      builder: (_) => page,
    );
  }
}

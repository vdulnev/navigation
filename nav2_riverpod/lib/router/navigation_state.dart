import '../models/product.dart';

/// Which of the four bottom tabs is active.
enum AppTab { shop, search, basket, account }

/// Pages that can appear in the shop tab stack.
sealed class ShopPage {
  const ShopPage();
}

class ShopListPage extends ShopPage {
  const ShopListPage();
}

class ShopDetailPage extends ShopPage {
  const ShopDetailPage(this.product);

  final Product product;
}

/// Pages that can appear in the search tab stack.
sealed class SearchPage {
  const SearchPage();
}

class SearchListPage extends SearchPage {
  const SearchListPage();
}

class SearchDetailPage extends SearchPage {
  const SearchDetailPage(this.product);

  final Product product;
}

/// Pages that can appear in the basket tab stack.
sealed class BasketPage {
  const BasketPage();
}

class BasketListPage extends BasketPage {
  const BasketListPage();
}

class CheckoutPage extends BasketPage {
  const CheckoutPage();
}

/// Full navigation state of the app.
///
/// This is the single source of truth owned by [NavigationNotifier].
/// The [AppRouterDelegate] reads it to build the [Navigator] page stack.
class NavigationState {
  const NavigationState({
    this.activeTab = AppTab.shop,
    this.shopStack = const [ShopListPage()],
    this.searchStack = const [SearchListPage()],
    this.basketStack = const [BasketListPage()],
    this.showLogin = false,
    this.showLogs = false,
  });

  final AppTab activeTab;
  final List<ShopPage> shopStack;
  final List<SearchPage> searchStack;
  final List<BasketPage> basketStack;
  final bool showLogin;
  final bool showLogs;

  NavigationState copyWith({
    AppTab? activeTab,
    List<ShopPage>? shopStack,
    List<SearchPage>? searchStack,
    List<BasketPage>? basketStack,
    bool? showLogin,
    bool? showLogs,
  }) => NavigationState(
    activeTab: activeTab ?? this.activeTab,
    shopStack: shopStack ?? this.shopStack,
    searchStack: searchStack ?? this.searchStack,
    basketStack: basketStack ?? this.basketStack,
    showLogin: showLogin ?? this.showLogin,
    showLogs: showLogs ?? this.showLogs,
  );
}

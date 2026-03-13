# getx_riverpod/ — GetX Navigation + Riverpod State Management

Implements the shared online-store flow using:
- **GetX** — navigation (route push/pop/replace) and DI-free global access
- **Riverpod 3** — all reactive state (auth, basket, search)

See the root `CLAUDE.md` for the app flow and screen descriptions.

---

## Key files

| File | Role |
|---|---|
| `lib/main.dart` | `ProviderScope` wrapping `App` |
| `lib/app.dart` | `GetMaterialApp` with `getPages` route table |
| `lib/router/app_routes.dart` | Named route constants |
| `lib/models/product.dart` | `Product` model + `kProducts` catalogue |
| `lib/widgets/nav_note_card.dart` | Shared annotation card |
| `lib/providers/auth_provider.dart` | `NotifierProvider<AuthNotifier, bool>` |
| `lib/providers/basket_provider.dart` | `NotifierProvider<BasketNotifier, List<BasketItem>>` |
| `lib/providers/search_provider.dart` | `searchQueryProvider` + derived `searchResultsProvider` |
| `lib/features/shell/screens/shell_screen.dart` | `BottomNavigationBar` + `IndexedStack` with basket badge |
| `lib/features/shop/screens/shop_screen.dart` | Product grid |
| `lib/features/shop/screens/item_detail_screen.dart` | Detail — reads args via `Get.arguments` |
| `lib/features/search/screens/search_screen.dart` | Live search — writes `searchQueryProvider` |
| `lib/features/basket/screens/basket_screen.dart` | Basket — reactive auth gate |
| `lib/features/basket/screens/checkout_screen.dart` | Checkout — clears basket via Riverpod |
| `lib/features/account/screens/account_screen.dart` | Profile or sign-in — fully reactive |
| `lib/features/auth/screens/login_screen.dart` | Modal login — `Get.back(result: true)` |

## GetX navigation patterns

| Pattern | Code | Notes |
|---|---|---|
| Push named route | `Get.toNamed(AppRoutes.shopDetail, arguments: product)` | No `BuildContext` needed |
| Await return value | `await Get.toNamed<bool>(AppRoutes.login)` | Returns value passed to `Get.back(result: …)` |
| Pop with value | `Get.back<bool>(result: true)` | Resolves the Future on the caller side |
| Pop without value | `Get.back()` | Caller receives `null` |
| Pass arguments | `Get.toNamed(…, arguments: product)` | Read in target via `Get.arguments` |
| Read arguments | `Get.arguments as Product` | Simpler than `ModalRoute.of(context).settings.arguments` |
| Slide-up modal | `GetPage(transition: Transition.downToUp)` | Approximates `fullscreenDialog: true` |

## Riverpod 3 state patterns

| Pattern | Provider | Notes |
|---|---|---|
| Auth state | `NotifierProvider<AuthNotifier, bool>` | `ref.watch(authProvider)` drives auth-gated widgets |
| Auth mutation | `ref.read(authProvider.notifier).login(…)` | Returns `Future<bool>` |
| Basket state | `NotifierProvider<BasketNotifier, List<BasketItem>>` | Immutable list, replaced on each mutation |
| Basket mutation | `ref.read(basketProvider.notifier).add(product)` | Rebuilds all watchers automatically |
| Basket badge | `ref.watch(basketProvider.select(…))` | Fine-grained rebuild — only when count changes |
| Search query | `NotifierProvider<SearchQueryNotifier, String>` | Replaces `StateProvider` removed in Riverpod 3 |
| Derived state | `Provider<List<Product>>` watching `searchQueryProvider` | Results recompute automatically on query change |

## Architecture: responsibilities by library

```
GetX owns:
  ─ Route push / pop / replace (Get.toNamed, Get.back, Get.offAllNamed)
  ─ Slide-up transition for login modal
  ─ Snackbar display (Get.snackbar)

Riverpod owns:
  ─ Auth state (bool)
  ─ Basket items (List<BasketItem>)
  ─ Search query (String) + derived search results (List<Product>)
  ─ Basket badge count in ShellScreen

No GetX controllers / Rx observables used — Riverpod is the single source
of reactive state. GetX is used purely for navigation.
```

## Key difference from Navigator 1 examples

| Aspect | Navigator 1 (nav1_tabs) | GetX + Riverpod |
|---|---|---|
| Navigation API | `Navigator.of(context).pushNamed(…)` | `Get.toNamed(…)` — no context |
| Login return value | `await Navigator.of(context, rootNavigator: true).pushNamed(login)` | `await Get.toNamed<bool>(login)` |
| Auth state | `AuthService` static class + `setState()` | `authProvider` Notifier + `ref.watch()` |
| Basket state | `BasketService` static list | `basketProvider` — immutable, reactive |
| Search filtering | `setState` + local filter in widget | Derived `searchResultsProvider` |
| Sign-out | `setState()` after logout | Just call `logout()` — watchers rebuild |

## Running

```sh
cd getx_riverpod
flutter run
```

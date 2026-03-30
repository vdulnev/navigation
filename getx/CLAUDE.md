# getx/ — GetX Navigation + GetX State Management

Implements the shared online-store flow using **GetX only** — both navigation
and reactive state management. No Riverpod, no Provider, no BLoC.

See the root `CLAUDE.md` for the app flow and screen descriptions.

---

## Key files

| File | Role |
|---|---|
| `lib/main.dart` | Entry point — no `ProviderScope` needed |
| `lib/app.dart` | `GetMaterialApp` with `getPages` route table + `Get.put` controller registration |
| `lib/router/app_routes.dart` | Named route constants |
| `lib/models/product.dart` | `Product` model + `kProducts` catalogue |
| `lib/widgets/nav_note_card.dart` | Shared annotation card |
| `lib/controllers/auth_controller.dart` | `GetxController` with `isLoggedIn.obs` — `login()` returns `sealed AuthResult` |
| `lib/controllers/basket_controller.dart` | `GetxController` with `items.obs` list |
| `lib/controllers/search_controller.dart` | `GetxController` with `query.obs` + computed `results` getter |
| `lib/controllers/login_form_controller.dart` | Sealed `LoginFormState` hierarchy + `Rx<LoginFormState>` — State pattern |
| `lib/features/shell/screens/shell_screen.dart` | `BottomNavigationBar` + `IndexedStack` with basket badge via `Obx` |
| `lib/features/shop/screens/shop_screen.dart` | Product grid |
| `lib/features/shop/screens/item_detail_screen.dart` | Detail — reads args via `Get.arguments` |
| `lib/features/search/screens/search_screen.dart` | Live search — writes `search.query` |
| `lib/features/basket/screens/basket_screen.dart` | Basket — reactive auth gate via `Obx` |
| `lib/features/basket/screens/checkout_screen.dart` | Checkout — clears basket via controller |
| `lib/features/account/screens/account_screen.dart` | Profile or sign-in — fully reactive |
| `lib/features/auth/screens/login_screen.dart` | Modal login — `Get.back(result: true)` |

## GetX navigation patterns

| Pattern | Code | Notes |
|---|---|---|
| Push named route | `Get.toNamed(AppRoutes.shopDetail, arguments: product)` | No `BuildContext` needed |
| Await return value | `await Get.toNamed(AppRoutes.login) != true` | **No type param** — `Get.toNamed<T>` crashes at runtime (GetX bug) |
| Pop with value | `Get.back<bool>(result: true)` | Resolves the Future on the caller side |
| Pop without value | `Get.back()` | Caller receives `null` |
| Pass arguments | `Get.toNamed(…, arguments: product)` | Read in target via `Get.arguments` |
| Read arguments | `Get.arguments as Product` | Simpler than `ModalRoute.of(context).settings.arguments` |
| Slide-up modal | `GetPage(transition: Transition.downToUp)` | Approximates `fullscreenDialog: true` |

## GetX state patterns

| Pattern | Implementation | Notes |
|---|---|---|
| Auth state | `AuthController` with `isLoggedIn.obs` | `Obx(() => auth.isLoggedIn.value)` drives auth-gated widgets |
| Auth mutation | `auth.login(email, password)` | Returns `Future<AuthResult>` — `AuthSuccess` or `AuthError(message)` |
| Login form state | `LoginFormController` with `Rx<LoginFormState>` | 4 sealed subclasses; `reset()` called on screen open |
| Login form transitions | `state.value = state.value.onEmailChanged(v)` | State pattern — each subclass owns its transition logic |
| Basket state | `BasketController` with `items.obs` | `.obs` RxList — mutations trigger `Obx` rebuilds automatically |
| Basket badge | `Obx(() => basket.itemCount)` | Badge count recomputed on every `items` change |
| Search query | `ProductSearchController` with `query.obs` | Updated on every keystroke |
| Derived state | `get results` reading `query.value` | `Obx` detects transitive dependency on `query` — rebuilds automatically |
| Controller DI | `Get.put(…, permanent: true)` in `App.build` | All controllers registered once, survive route changes |
| Controller access | `Get.find<T>()` | No `BuildContext` required |

## Architecture: GetX owns everything

```
GetX owns:
  ─ Route push / pop / replace (Get.toNamed, Get.back)
  ─ Slide-up transition for login modal
  ─ Snackbar display (Get.snackbar)
  ─ Auth state (RxBool)
  ─ Basket items (RxList<BasketItem>)
  ─ Search query (RxString) + computed search results
  ─ Login form state (Rx<LoginFormState>)
  ─ Dependency injection (Get.put / Get.find)

No Riverpod, no Provider — GetxController + .obs + Obx is the single
reactive primitive for all state.
```

## Key difference from getx_riverpod

| Aspect | getx_riverpod | getx (this variant) |
|---|---|---|
| State management | Riverpod 3 (`NotifierProvider`, `ref.watch`) | GetX (`GetxController`, `.obs`, `Obx`) |
| Widgets | `ConsumerWidget` / `ConsumerStatefulWidget` | `StatelessWidget` / `StatefulWidget` |
| State access | `ref.watch(provider)` / `ref.read(provider.notifier)` | `Get.find<Controller>()` |
| Reactive rebuild | `ref.watch` in `build()` | `Obx(() => …)` wrapper |
| Controller lifecycle | Riverpod manages via `ProviderScope` | `Get.put(…, permanent: true)` in `App` |
| Login form reset | `autoDispose` on provider | Manual `controller.reset()` on screen open |
| Dependencies | `get` + `flutter_riverpod` | `get` only |

## Running

```sh
cd getx
flutter run
```

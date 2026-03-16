# gorouter_riverpod/ — GoRouter + Riverpod 3

Implements the shared online-store flow using:
- **GoRouter** — declarative routing, `StatefulShellRoute`, `redirect` auth guard
- **Riverpod 3** — all reactive state (auth, basket, search, login form)

See the root `CLAUDE.md` for the app flow and screen descriptions.

---

## Key files

| File | Role |
|---|---|
| `lib/main.dart` | `ProviderScope` wrapping `App` |
| `lib/app.dart` | `MaterialApp.router` consuming `routerProvider` |
| `lib/router/app_routes.dart` | Named route path constants |
| `lib/router/app_router.dart` | `RouterNotifier` + `GoRouter` config + `StatefulShellRoute` |
| `lib/models/product.dart` | `Product` model + `kProducts` catalogue |
| `lib/widgets/nav_note_card.dart` | Shared annotation card |
| `lib/providers/auth_provider.dart` | `NotifierProvider<AuthNotifier, bool>` — `login()` returns `sealed AuthResult` |
| `lib/providers/basket_provider.dart` | `NotifierProvider<BasketNotifier, List<BasketItem>>` — pure state, no navigation |
| `lib/providers/search_provider.dart` | `searchQueryProvider` + derived `searchResultsProvider` |
| `lib/providers/login_state_provider.dart` | Sealed `LoginFormState` hierarchy — `submit()` returns `bool` |
| `lib/features/shell/screens/shell_screen.dart` | `StatefulNavigationShell` + `BottomNavigationBar` |
| `lib/features/shop/screens/shop_screen.dart` | Product grid — `context.push` with `extra` |
| `lib/features/shop/screens/item_detail_screen.dart` | Detail — receives `Product` via `state.extra` |
| `lib/features/search/screens/search_screen.dart` | Live search — detail stays in search branch |
| `lib/features/basket/screens/basket_screen.dart` | Auth-gated by router `redirect`; shows note |
| `lib/features/basket/screens/checkout_screen.dart` | Order summary — `context.pop()` |
| `lib/features/account/screens/account_screen.dart` | Profile or sign-in prompt |
| `lib/features/auth/screens/login_screen.dart` | Modal login — `context.pop(true)` |

---

## GoRouter patterns

### StatefulShellRoute — per-tab back-stacks

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      ShellScreen(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: '/shop', ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/search', ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/basket', ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/account', ...)]),
  ],
)
```

Each branch owns its own navigator. Pushing `/shop/detail` stays inside the
shop branch's stack; pushing `/search/detail` stays inside search's stack.

### RouterNotifier — auth guard without imperative navigation

```dart
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<bool>(authProvider, (prev, next) => notifyListeners());
  }
  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _ref.read(authProvider);
    if (!isLoggedIn && state.matchedLocation.startsWith('/basket')) {
      return AppRoutes.login;
    }
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier, // re-evaluates redirect on auth change
    redirect: notifier.redirect,
    ...
  );
});
```

On logout, `authProvider` emits `false` → `notifyListeners()` → GoRouter
calls `redirect` → user is redirected to `/login` automatically.

### Typed push / pop — returning a value from a route

```dart
// Caller (widget):
final loggedIn = await context.push<bool>(AppRoutes.login);
if (loggedIn == true) { /* handle success */ }

// Login screen:
if (context.mounted) context.pop(true);
```

`context.mounted` is checked at `LoginScreen.build` scope (not inside a
child widget) so the context is valid for the full route lifetime.

### Passing objects via `extra`

```dart
// Push:
context.push(AppRoutes.shopDetail, extra: product);

// Receive:
ItemDetailScreen(product: state.extra! as Product)
```

### Full-screen modal outside the shell

```dart
GoRoute(
  path: AppRoutes.login,
  pageBuilder: (context, state) =>
      const MaterialPage(fullscreenDialog: true, child: LoginScreen()),
)
```

Defined outside `StatefulShellRoute` so it covers the entire screen
(shell chrome is hidden during login).

---

## Riverpod 3 state patterns

| Pattern | Provider | Notes |
|---|---|---|
| Auth state | `NotifierProvider<AuthNotifier, bool>` | Drives `RouterNotifier` → router redirect |
| Auth mutation | `ref.read(authProvider.notifier).login(…)` | Returns `Future<AuthResult>` — `AuthSuccess` or `AuthError(message)` |
| Login form state | `NotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>` | 4 sealed subclasses; resets on pop |
| Login form transitions | `state = state.onEmailChanged(v)` | State pattern — each subclass owns transition logic |
| Login submit | `submit()` returns `bool` | Widget calls `context.pop(true)` on success |
| Basket state | `NotifierProvider<BasketNotifier, List<BasketItem>>` | Pure state — no navigation |
| Basket badge | `ref.watch(basketProvider.select(…))` | Fine-grained rebuild — only on count change |
| Search query | `NotifierProvider<SearchQueryNotifier, String>` | Replaces removed `StateProvider` |
| Derived state | `Provider<List<Product>>` watching `searchQueryProvider` | Auto-recomputes on query change |

### Login form sealed state hierarchy

```
LoginFormState (sealed)
  ├─ LoginFormEditing   — editing; optional LoginCredentialsError
  ├─ LoginFormCorrect   — both fields valid; exposes credentials getter
  ├─ LoginFormInvalid   — server error; carries LoginServerError
  └─ LoginFormSubmitting — in-flight; ignores keystrokes
```

---

## Architecture: GoRouter vs getx_riverpod

| Aspect | getx_riverpod | gorouter_riverpod |
|---|---|---|
| Navigation API | `Get.toNamed` — no context | `context.push` — context required |
| Navigation location | Providers | Widgets (screens) |
| Auth guard | Imperative check before push | Declarative `redirect` in router |
| Logout redirect | `Get.offAllNamed` in provider | `RouterNotifier` triggers redirect |
| Login return value | `await Get.toNamed(…) != true` | `await context.push<bool>(…) == true` |
| `submit()` | `void` — calls `Get.back` itself | `bool` — widget calls `context.pop` |

---

## Running

```sh
cd gorouter_riverpod
flutter run
```

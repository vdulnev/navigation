# Flutter Navigation Examples — Shared Context

## Rules

- **Never commit without an explicit commit command from the user.**

This folder contains Flutter apps that demonstrate different navigation
approaches. Each sub-folder is a self-contained example implemented with a
different navigation strategy.

---

## Example 1 — Login / Profile / Settings flow

A linear flow with a splash gate, login, and nested profile editing.
Focuses on stack manipulation: replace, clear-and-push, push-with-return-value.

### Screens

| Screen | Role |
|---|---|
| SplashScreen | Startup gate — checks auth state, redirects |
| LoginScreen | Login form |
| HomeScreen | Main hub, logout action |
| ProfileScreen | Receives args, returns edited name to caller |
| EditProfileScreen | Returns a value to ProfileScreen |
| SettingsScreen | Plain push/pop destination |

### Navigation flow

```
SplashScreen (2 s)
  ├─ not logged in → replace → LoginScreen
  │                                 │ login ok
  │                           replace → HomeScreen ──┐
  │                                                   │ logout
  │                              clear stack + go ───┘
  │
  └─ already logged in → replace → HomeScreen
                                       │
                     ┌─────────────────┤
                     │                 │
                   push             push
                ProfileScreen    SettingsScreen
                     │ push           │
                EditProfile       go back
                     │ return(name)
                ProfileScreen
                     │ return(name)
                HomeScreen (snackbar)
```

### Key navigation behaviours

| Behaviour | Where |
|---|---|
| Replace current route (no Back) | Splash → Login, Login → Home |
| Clear entire stack + go to route | Home logout → Login |
| Push and await a return value | Home → Profile → receives edited name |
| Pass arguments to a route | Home → Profile, Profile → EditProfile |
| Return a value on pop | EditProfile → Profile, Profile → Home |
| Plain push / pop | Home → Settings |

---

## Example 2 — Online Store with Tab Navigation

A tab-based store where browsing and searching are open to all users, but
adding to the basket and checkout require authentication.
Focuses on nested navigators, per-tab back-stacks, and auth-gating.

### Screens

| Screen | Role |
|---|---|
| ShellScreen | Tab scaffold — BottomNavigationBar + 4 independent Navigators |
| ShopScreen | Product grid (browse) |
| ItemDetailScreen | Product detail — receives args, auth guard |
| SearchScreen | Live search across catalogue |
| BasketScreen | Basket contents — auth-gated |
| CheckoutScreen | Order summary + place order |
| AccountScreen | Sign-in prompt or profile view |
| LoginScreen | Modal login — returns bool to caller |

### Navigation flow

```
ShellScreen (always present, manages tabs)
  │
  ├─ Shop tab (own Navigator)
  │    ShopScreen
  │      │ push(detail)
  │    ItemDetailScreen
  │      │ "Add to Basket" → not logged in
  │      │   rootNavigator.push → LoginScreen (modal, returns bool)
  │      └─ pop → ShopScreen
  │
  ├─ Search tab (own Navigator)
  │    SearchScreen
  │      │ push(detail)           ← stays in Search tab's stack
  │    ItemDetailScreen
  │      └─ pop → SearchScreen
  │
  ├─ Basket tab (own Navigator)
  │    ├─ not logged in → sign-in prompt
  │    │     rootNavigator.push → LoginScreen (modal)
  │    └─ logged in → BasketScreen
  │         │ push(checkout)
  │       CheckoutScreen
  │         │ pop → BasketScreen
  │
  └─ Account tab (own Navigator)
       ├─ not logged in → sign-in view
       │     rootNavigator.push → LoginScreen (modal)
       └─ logged in → profile + sign-out
```

### Key navigation behaviours

| Behaviour | Where |
|---|---|
| `IndexedStack` — preserve tab state | ShellScreen |
| Per-tab `Navigator` with `GlobalKey` | ShellScreen |
| Tap active tab icon → pop to tab root | ShellScreen |
| Android back pops within tab first | ShellScreen (`PopScope`) |
| `rootNavigator: true` — modal over tabs | Auth guard in Shop, Search, Basket, Account |
| `fullscreenDialog` login modal | `app.dart` |
| `pop(true)` — return value across navigators | LoginScreen |
| Push within tab Navigator | Shop → detail, Basket → checkout |
| `setState` after modal closes | BasketScreen, AccountScreen |

---

---

## Example 3 — Online Store with GetX + Riverpod 3

Same screen layout and navigation flow as Example 2.
Replaces Navigator 1 with GetX routes and replaces local state / setState
with Riverpod 3 providers. No nested Navigators — single flat GetX navigator.

### Key navigation behaviours

| Behaviour | Where |
|---|---|
| Push named route — no `BuildContext` | `Get.toNamed(AppRoutes.shopDetail, arguments: product)` |
| Read route arguments | `Get.arguments as Product` |
| Slide-up login modal | `GetPage(transition: Transition.downToUp)` |
| Await return value (no type param — GetX bug) | `await Get.toNamed(AppRoutes.login) != true` |
| Pop with value — no `BuildContext` | `Get.back<bool>(result: true)` |

### Key state patterns

| Pattern | Provider / type |
|---|---|
| Auth state | `NotifierProvider<AuthNotifier, bool>` — all watchers rebuild on change |
| Auth mutation result | `sealed class AuthResult` — `AuthSuccess` / `AuthError(message)` |
| Basket state | `NotifierProvider<BasketNotifier, List<BasketItem>>` — immutable list |
| Fine-grained rebuild | `ref.watch(basketProvider.select(…))` — basket badge only |
| Derived state | `Provider<List<Product>>` watching `searchQueryProvider` |
| Login form state | `sealed class LoginFormState` — 4 subclasses (see below) |
| Login form errors | `sealed class LoginCredentialsResult` — `LoginCredentialsCorrect` / `LoginCredentialsError` |

### Login form sealed state hierarchy

```
LoginFormState (sealed)
  ├─ LoginFormEditing   — editing; carries optional LoginCredentialsError
  ├─ LoginFormCorrect   — both fields valid; exposes credentials getter
  ├─ LoginFormInvalid   — server error received; carries LoginServerError
  └─ LoginFormSubmitting — network call in flight; ignores keystrokes
```

Each subclass owns its own transition logic (`onEmailChanged` /
`onPasswordChanged`). `LoginFormNotifier` is a thin dispatcher:
`void setEmail(String v) => state = state.onEmailChanged(v);`

---

## Example 4 — Online Store with GoRouter + Riverpod 3

Same screen layout and navigation flow as Example 2.
Replaces Navigator 1 with GoRouter's declarative API and uses Riverpod 3
for all state. Auth guard lives at the router level via `redirect`.

### Key navigation behaviours

| Behaviour | Where |
|---|---|
| `StatefulShellRoute.indexedStack` — per-tab back-stack | `app_router.dart` |
| Router-level auth guard (no imperative nav) | `RouterNotifier.redirect` + `refreshListenable` |
| Push with typed return value | `context.push<bool>(AppRoutes.login)` |
| Pop with value | `context.pop(true)` — resolves the Future above |
| Pass `extra` object to route | `context.push(AppRoutes.shopDetail, extra: product)` |
| Read `extra` in destination | `state.extra! as Product` |
| Full-screen modal outside shell | `GoRoute` for `/login` using `MaterialPage(fullscreenDialog: true)` |
| Tab root pop on active tab tap | `navigationShell.goBranch(index, initialLocation: true)` |

### Key GoRouter patterns

```
RouterNotifier extends ChangeNotifier
  └─ listens to authProvider via ref.listen
  └─ calls notifyListeners() on every auth change
  └─ GoRouter(refreshListenable: notifier, redirect: notifier.redirect)

// Auth guard — no screen code needed
String? redirect(BuildContext context, GoRouterState state) {
  if (!isLoggedIn && loc.startsWith('/basket')) return AppRoutes.login;
  return null;
}

// Typed push/pop
final loggedIn = await context.push<bool>(AppRoutes.login); // in widget
if (context.mounted) context.pop(true);                     // in LoginScreen
```

### Architecture difference from getx_riverpod

| Aspect | getx_riverpod | gorouter_riverpod |
|---|---|---|
| Navigation API | `Get.toNamed` — no context needed | `context.push` — context required |
| Navigation location | Providers (`BasketNotifier.addWithAuthGuard`) | Widgets (screens call `context.push`) |
| Auth guard | Imperative check in provider before push | Declarative `redirect` in router |
| Logout redirect | `Get.offAllNamed` in provider | `RouterNotifier` triggers `redirect` automatically |
| Login return value | `await Get.toNamed(…) != true` | `await context.push<bool>(…) == true` |
| `submit()` return | `void` (calls `Get.back` itself) | `bool` (widget decides whether to `context.pop`) |

---

## Sub-folders

| Folder | Example | Navigation approach |
|---|---|---|
| `nav1/` | Login / Profile / Settings | Navigator 1.0 — imperative `Navigator` API |
| `nav1_tabs/` | Online Store + Tabs | Navigator 1.0 — nested `Navigator` widgets + `BottomNavigationBar` |
| `nav1_drawer/` | Online Store + Drawer | Navigator 1.0 — single flat Navigator + `Drawer` + `pushNamedAndRemoveUntil` |
| `nav1_rail/` | Online Store + Rail | Navigator 1.0 — nested `Navigator` widgets + `NavigationRail` (same structure as nav1_tabs, different chrome) |
| `getx/` | Online Store | GetX only — `GetxController` + `.obs` + `Obx` for both navigation and state, sealed `LoginFormState` |
| `getx_riverpod/` | Online Store | GetX navigation + Riverpod 3 state — sealed `LoginFormState`, `AuthResult`, `NotifierProvider` |
| `gorouter_riverpod/` | Online Store | GoRouter + Riverpod 3 — `StatefulShellRoute.indexedStack`, `RouterNotifier`, redirect auth guard, `context.push<T>` return value |

# nav1_tabs/ — Navigator 1.0 Tab Navigation Implementation

Implements the shared online-store flow using Navigator 1.0 with a
`BottomNavigationBar` and per-tab nested `Navigator` widgets.
See the root `CLAUDE.md` for the app flow and screen descriptions.

---

## Key files

| File | Role |
|---|---|
| `lib/app.dart` | `MaterialApp` + top-level route table (shell + login) |
| `lib/router/app_routes.dart` | Named route constants |
| `lib/models/product.dart` | `Product` model + `kProducts` catalogue |
| `lib/widgets/nav_note_card.dart` | Shared annotation card shown on each screen |
| `lib/features/auth/services/auth_service.dart` | Mock auth (no network) |
| `lib/features/shop/services/basket_service.dart` | In-memory basket |
| `lib/features/shell/screens/shell_screen.dart` | Tab scaffold — `IndexedStack` + 4 `Navigator` widgets |
| `lib/features/shop/screens/shop_screen.dart` | Product grid (browse) |
| `lib/features/shop/screens/item_detail_screen.dart` | Product detail — receives args, auth guard |
| `lib/features/search/screens/search_screen.dart` | Live search |
| `lib/features/basket/screens/basket_screen.dart` | Basket — auth-gated tab |
| `lib/features/basket/screens/checkout_screen.dart` | Checkout flow |
| `lib/features/account/screens/account_screen.dart` | Sign-in or profile view |
| `lib/features/auth/screens/login_screen.dart` | Modal login — returns `bool` |

## Navigator 1 concepts demonstrated

| Concept | Where | What it does |
|---|---|---|
| `IndexedStack` | `ShellScreen` | Keeps all 4 tab widget trees mounted; no state is lost on tab switch |
| Per-tab `Navigator` + `GlobalKey` | `ShellScreen` | Each tab owns an independent back-stack |
| Tap-to-root | `ShellScreen._onTabTapped` | Tapping the active tab icon pops to the tab's first route |
| `PopScope` + back-button delegation | `ShellScreen` | Android back pops within the current tab before exiting the app |
| `rootNavigator: true` | Shop, Search, Basket, Account | Pushes `/login` above the tab shell, not inside a tab's stack |
| `fullscreenDialog: true` | `app.dart` login route | Login slides up as a modal dialog |
| `pop(value)` | `LoginScreen` | Returns `true` to the caller on success; `null` on dismiss |
| Push within tab Navigator | Shop → detail, Basket → checkout | `Navigator.of(context)` finds the nearest (tab) Navigator |
| `ModalRoute.settings.arguments` | `ItemDetailScreen` | Reads the `Product` passed via `pushNamed(…, arguments: product)` |
| `setState` after pop | `BasketScreen`, `AccountScreen` | Rebuilds the screen when the login modal closes |

## Auth-gated screens

| Screen | Behaviour when not logged in |
|---|---|
| Basket tab | Shows a "Sign in" prompt; basket contents hidden |
| "Add to Basket" (Shop, Search, Detail) | Intercepts the action and presents login modal first |
| Account tab | Shows sign-in view; switches to profile after login |

## Running

```sh
cd nav1_tabs
flutter run
```

# nav1_drawer/ — Navigator 1.0 Drawer Navigation Implementation

Implements the shared online-store flow using Navigator 1.0 with a `Drawer`
and a **single flat Navigator** (no nested navigators).
See the root `CLAUDE.md` for the app flow and screen descriptions.

The key architectural difference from `nav1_tabs/`: there is only **one**
Navigator in this app. All routes — section screens, detail screens, login —
live in the same back-stack. This eliminates the need for `rootNavigator: true`
anywhere in the codebase.

---

## Key files

| File | Role |
|---|---|
| `lib/app.dart` | `MaterialApp` + flat route table (all routes in one place) |
| `lib/router/app_routes.dart` | Named route constants |
| `lib/models/product.dart` | `Product` model + `kProducts` catalogue |
| `lib/widgets/nav_note_card.dart` | Shared annotation card |
| `lib/widgets/app_drawer.dart` | Shared `Drawer` — handles section switching |
| `lib/features/auth/services/auth_service.dart` | Mock auth |
| `lib/features/shop/services/basket_service.dart` | In-memory basket |
| `lib/features/shop/screens/shop_screen.dart` | Product grid |
| `lib/features/shop/screens/item_detail_screen.dart` | Product detail |
| `lib/features/search/screens/search_screen.dart` | Live search |
| `lib/features/basket/screens/basket_screen.dart` | Basket — auth-gated |
| `lib/features/basket/screens/checkout_screen.dart` | Checkout |
| `lib/features/account/screens/account_screen.dart` | Sign-in or profile |
| `lib/features/auth/screens/login_screen.dart` | Login — returns `bool` |

## Navigator 1 concepts demonstrated

| Concept | Where | What it does |
|---|---|---|
| `pushNamedAndRemoveUntil` (section switching) | `AppDrawer._navigate` | Clears the entire stack and pushes the target section fresh |
| `pushNamedAndRemoveUntil` (sign-out) | `AccountScreen._signOut` | Same mechanism — returns to Shop with a clean stack |
| `Navigator.pop()` closes drawer | `AppDrawer._navigate` | The Drawer is an overlay route; pop() dismisses it |
| `DrawerHeader` with live auth state | `AppDrawer` | Shows user email or "Not signed in" |
| Active section highlighting | `AppDrawer._sectionTile` | `selected: route == activeRoute` |
| Flat route table | `app.dart` | All routes in one `onGenerateRoute` — no nested Navigator widgets |
| Plain `pushNamed` auth guard | Shop, Search, Basket, Account | No `rootNavigator: true` — single Navigator, always reachable |
| `fullscreenDialog: true` | `app.dart` login route | Login slides up as a modal without a special flag at the call site |
| `pop(true)` — return value | `LoginScreen` | Returns success bool to any awaiting caller |
| `pushNamed` within section | Shop → detail, Basket → checkout | Sub-screens pushed on the same Navigator; drawer absent |
| `ModalRoute.settings.arguments` | `ItemDetailScreen` | Reads `Product` passed via `pushNamed(…, arguments: product)` |
| `setState` after pop | `BasketScreen`, `AccountScreen` | Rebuilds auth-gated screen when login modal closes |

## Comparison with nav1_tabs

| Aspect | nav1_drawer | nav1_tabs |
|---|---|---|
| Navigator count | 1 (flat) | 5 (root + 4 tab Navigators) |
| Section switching | `pushNamedAndRemoveUntil` | Switch `IndexedStack` index |
| Tab state preserved? | No — sections are recreated | Yes — `IndexedStack` keeps them mounted |
| `rootNavigator: true` | Never needed | Required for login auth guard |
| Back from section root | Exits app | Stays in app (tab shell persists) |
| Navigation chrome | `Drawer` | `BottomNavigationBar` |

## Running

```sh
cd nav1_drawer
flutter run
```

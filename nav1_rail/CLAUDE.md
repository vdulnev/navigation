# nav1_rail/ — Navigator 1.0 Navigation Rail Implementation

Implements the shared online-store flow using Navigator 1.0 with a
`NavigationRail` and per-section nested `Navigator` widgets.
See the root `CLAUDE.md` for the app flow and screen descriptions.

The Navigator architecture is **identical to `nav1_tabs/`**: an `IndexedStack`
holds four section Navigators each identified by a `GlobalKey<NavigatorState>`.
Only the navigation chrome differs — `NavigationRail` renders vertically on the
left instead of `BottomNavigationBar` at the bottom.

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
| `lib/features/shell/screens/shell_screen.dart` | Rail scaffold — `Row` + `NavigationRail` + `IndexedStack` + 4 `Navigator` widgets |
| `lib/features/shop/screens/shop_screen.dart` | Product grid (browse) |
| `lib/features/shop/screens/item_detail_screen.dart` | Product detail — receives args, auth guard |
| `lib/features/search/screens/search_screen.dart` | Live search |
| `lib/features/basket/screens/basket_screen.dart` | Basket — auth-gated section |
| `lib/features/basket/screens/checkout_screen.dart` | Checkout flow |
| `lib/features/account/screens/account_screen.dart` | Sign-in or profile view |
| `lib/features/auth/screens/login_screen.dart` | Modal login — returns `bool` |

## Navigator 1 concepts demonstrated

| Concept | Where | What it does |
|---|---|---|
| `IndexedStack` | `ShellScreen` | Keeps all 4 section widget trees mounted; no state is lost on section switch |
| Per-section `Navigator` + `GlobalKey` | `ShellScreen` | Each section owns an independent back-stack |
| Tap-to-root | `ShellScreen._onDestinationSelected` | Tapping the active rail destination pops to the section's first route |
| `PopScope` + back-button delegation | `ShellScreen` | Android back pops within the current section before exiting the app |
| `rootNavigator: true` | Shop, Search, Basket, Account | Pushes `/login` above the rail shell, not inside a section's stack |
| `fullscreenDialog: true` | `app.dart` login route | Login slides up as a modal dialog |
| `pop(value)` | `LoginScreen` | Returns `true` to the caller on success; `null` on dismiss |
| Push within section Navigator | Shop → detail, Basket → checkout | `Navigator.of(context)` finds the nearest (section) Navigator |
| `ModalRoute.settings.arguments` | `ItemDetailScreen` | Reads the `Product` passed via `pushNamed(…, arguments: product)` |
| `setState` after pop | `BasketScreen`, `AccountScreen` | Rebuilds the screen when the login modal closes |

## Layout: NavigationRail in a Row

```
Scaffold
└── body: Row
    ├── NavigationRail          ← vertical chrome on the left
    ├── VerticalDivider
    └── Expanded
        └── IndexedStack        ← section content fills remaining width
            ├── Navigator[0]    ← Shop
            ├── Navigator[1]    ← Search
            ├── Navigator[2]    ← Basket
            └── Navigator[3]    ← Account
```

`NavigationRail` requires a `Row` layout — it cannot be placed in
`Scaffold.bottomNavigationBar`. The `Expanded` widget gives the `IndexedStack`
all remaining horizontal space.

## Comparison with nav1_tabs and nav1_drawer

| Aspect | nav1_rail | nav1_tabs | nav1_drawer |
|---|---|---|---|
| Navigator count | 5 (root + 4 sections) | 5 (root + 4 tabs) | 1 (flat) |
| Chrome widget | `NavigationRail` | `BottomNavigationBar` | `Drawer` |
| Chrome position | Left side (vertical) | Bottom (horizontal) | Slide-in overlay |
| Section state preserved? | Yes — `IndexedStack` | Yes — `IndexedStack` | No — sections recreated |
| `rootNavigator: true` | Required for login | Required for login | Never needed |
| Navigator architecture | Nested (per-section) | Nested (per-tab) | Flat (single) |

## Running

```sh
cd nav1_rail
flutter run
```

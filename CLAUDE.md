# Flutter Navigation Examples — Shared Context

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

## Sub-folders

| Folder | Example | Navigation approach |
|---|---|---|
| `nav1/` | Login / Profile / Settings | Navigator 1.0 — imperative `Navigator` API |
| `nav1_tabs/` | Online Store + Tabs | Navigator 1.0 — nested `Navigator` widgets + `BottomNavigationBar` |
| `nav1_drawer/` | Online Store + Drawer | Navigator 1.0 — single flat Navigator + `Drawer` + `pushNamedAndRemoveUntil` |

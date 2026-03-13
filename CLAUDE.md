# Flutter Navigation Examples — Shared Context

This folder contains Flutter apps that demonstrate different navigation
approaches. Each sub-folder is a self-contained example of the same
**mocked login flow** implemented with a different navigation strategy.

---

## App flow — Mocked Login / Profile / Settings

All examples implement the same screens and transitions:

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

## Sub-folders

| Folder | Navigation approach |
|---|---|
| `nav1/` | Navigator 1.0 — imperative `Navigator` API |

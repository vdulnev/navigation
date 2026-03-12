# Navigator 1 Examples — Shared Context

This folder contains Flutter apps that demonstrate **Navigator 1.0** (the
imperative `Navigator` API).  Each sub-folder is a self-contained example.

---

## nav1/ — Mocked Login Flow

**Purpose:** showcase every common Navigator 1 operation through a realistic
login/profile/settings flow.

### Key files

| File | Role |
|---|---|
| `lib/app.dart` | `MaterialApp` + `onGenerateRoute` route table |
| `lib/router/app_routes.dart` | All named route constants |
| `lib/features/auth/services/auth_service.dart` | Mock auth (no network) |
| `lib/features/auth/screens/splash_screen.dart` | Startup gate |
| `lib/features/auth/screens/login_screen.dart` | Login form |
| `lib/features/home/screens/home_screen.dart` | Hub / logout |
| `lib/features/profile/screens/profile_screen.dart` | Receives + returns args |
| `lib/features/profile/screens/edit_profile_screen.dart` | Returns value via pop |
| `lib/features/settings/screens/settings_screen.dart` | Plain push/pop |

### Navigator 1 concepts demonstrated

| Concept | Where | What it does |
|---|---|---|
| `pushReplacementNamed` | Splash → Login/Home | Replaces splash; no Back button |
| `pushReplacementNamed` | Login → Home | Removes login from stack after auth |
| `pushNamedAndRemoveUntil` | Home logout | Clears entire stack, lands on Login |
| `pushNamed` + await return value | Home → Profile | Gets edited name back from Profile |
| `ModalRoute.of(context).settings.arguments` | Profile, EditProfile | Reads typed args passed to pushNamed |
| `pop(value)` | EditProfile, Profile | Returns data to the caller |
| `pushNamed` / `pop()` | Home → Settings | Plain push/pop navigation |
| `onGenerateRoute` switch | `app.dart` | Central route factory with typed `settings` forwarded |

### Navigation flow

```
SplashScreen (2 s)
  ├─ not logged in → pushReplacementNamed → LoginScreen
  │                                              │ login ok
  │                               pushReplacementNamed → HomeScreen ──┐
  │                                                                    │ logout
  │                                       pushNamedAndRemoveUntil ────┘
  │
  └─ already logged in → pushReplacementNamed → HomeScreen
                                                    │
                              ┌─────────────────────┤
                              │                     │
                          pushNamed             pushNamed
                         ProfileScreen        SettingsScreen
                              │ pushNamed           │
                         EditProfile          Navigator.pop()
                              │ pop(name)
                         ProfileScreen
                              │ pop(name)
                         HomeScreen (snackbar)
```

### Running

```sh
cd nav1
flutter run
```

### Conventions used across all examples in this folder

- Feature-first folder layout: `lib/features/<feature>/screens/`
- Route constants in `lib/router/app_routes.dart`
- Each screen carries a `_NavNoteCard` that names the Navigator 1 pattern
  it demonstrates — useful for learning purposes
- Mock services live in `lib/features/<feature>/services/`
- No state management library — plain `StatefulWidget` is enough to keep the
  focus on navigation

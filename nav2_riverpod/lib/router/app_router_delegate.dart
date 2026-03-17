import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/talker.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/logs/screens/logs_screen.dart';
import '../features/shell/screens/shell_screen.dart';
import 'navigation_provider.dart';
import 'navigation_state.dart';
import 'talker_navigator_observer.dart';

/// Custom [RouterDelegate] — the heart of the Navigator 2 implementation.
///
/// Navigator 2 concepts demonstrated:
///
/// * **[RouterDelegate]**: owns the [Navigator] and rebuilds its page list
///   whenever the app's navigation state changes.
///
/// * **[PopNavigatorRouterDelegateMixin]**: wires up [navigatorKey] so the
///   delegate's [popRoute] can delegate to the Navigator (e.g. Android back).
///
/// * **[ChangeNotifier]**: calling [notifyListeners] tells the [Router] widget
///   to rebuild, which calls [build] again and rebuilds the [Navigator].
///
/// * **Page-based navigation**: pages are immutable value objects ([MaterialPage]).
///   The [Navigator] diffs the old and new page lists to decide which routes
///   to push/pop — no imperative push/pop calls needed.
///
/// * **[onDidRemovePage]**: called when the user pops a page (e.g. swipe-back
///   on iOS). We propagate this to [NavigationNotifier.onBack] so state stays
///   in sync with the visual stack.
class AppRouterDelegate extends RouterDelegate<NavigationState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<NavigationState> {
  AppRouterDelegate(this._ref) {
    // Re-notify the Router whenever navigation state changes.
    _ref.listen(navigationProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  NavigationState get currentConfiguration => _ref.read(navigationProvider);

  @override
  Widget build(BuildContext context) {
    final state = _ref.watch(navigationProvider);

    return Navigator(
      key: navigatorKey,
      observers: [TalkerNavigatorObserver(talker, label: 'root')],
      onDidRemovePage: (page) {
        // Sync state when the user pops a page imperatively (e.g. iOS swipe).
        _ref.read(navigationProvider.notifier).onBack();
      },
      pages: [
        const MaterialPage(key: ValueKey('shell'), child: ShellScreen()),
        if (state.showLogin)
          const MaterialPage(
            key: ValueKey('login'),
            fullscreenDialog: true,
            child: LoginScreen(),
          ),
        if (state.showLogs)
          const MaterialPage(key: ValueKey('logs'), child: LogsScreen()),
      ],
    );
  }

  @override
  Future<bool> popRoute() async {
    return _ref.read(navigationProvider.notifier).onBack();
  }

  @override
  Future<void> setNewRoutePath(NavigationState configuration) async {
    // Restore state from URL / deep link parsed by AppRouteParser.
    // No-op for in-app navigation — state is driven by Riverpod.
  }
}

/// Riverpod provider for the delegate.
///
/// Declared here to keep router setup in one place.
final routerDelegateProvider = Provider<AppRouterDelegate>((ref) {
  return AppRouterDelegate(ref);
});

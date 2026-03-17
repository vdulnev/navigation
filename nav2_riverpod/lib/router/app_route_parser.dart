import 'package:flutter/material.dart';

import 'navigation_state.dart';

/// Converts between a URL string and [NavigationState].
///
/// Navigator 2 concept: [RouteInformationParser] sits between the platform
/// (URL bar / deep links) and the [RouterDelegate]. It translates a URL into
/// app state on launch and converts state back to a URL for the address bar.
///
/// For this demo the URL scheme is kept minimal — only the active tab is
/// reflected in the URL so browser back/forward and deep links work for
/// top-level tabs.
class AppRouteParser extends RouteInformationParser<NavigationState> {
  const AppRouteParser();

  @override
  Future<NavigationState> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    final path = uri.path;

    if (path.startsWith('/search')) {
      return const NavigationState(activeTab: AppTab.search);
    }
    if (path.startsWith('/basket')) {
      return const NavigationState(activeTab: AppTab.basket);
    }
    if (path.startsWith('/account')) {
      return const NavigationState(activeTab: AppTab.account);
    }
    return const NavigationState(activeTab: AppTab.shop);
  }

  @override
  RouteInformation? restoreRouteInformation(NavigationState configuration) {
    final path = switch (configuration.activeTab) {
      AppTab.shop => '/',
      AppTab.search => '/search',
      AppTab.basket => '/basket',
      AppTab.account => '/account',
    };
    return RouteInformation(uri: Uri.parse(path));
  }
}

import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// A [NavigatorObserver] that logs push/pop/replace/remove events via Talker.
///
/// Navigator 2 concept: [NavigatorObserver]s are passed to [Navigator.observers]
/// and are notified of every route transition. Using one per [Navigator]
/// (root + each tab) gives full visibility into all navigation events.
class TalkerNavigatorObserver extends NavigatorObserver {
  TalkerNavigatorObserver(this.talker, {this.label = 'nav'});

  final Talker talker;

  /// Prefix added to each log message to identify which Navigator fired.
  final String label;

  String _name(Route<dynamic> route) =>
      route.settings.name ?? route.runtimeType.toString();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    talker.info('[$label] push → ${_name(route)}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    talker.info('[$label] pop  ← ${_name(route)}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    talker.info(
      '[$label] replace ${oldRoute != null ? _name(oldRoute) : '?'} → '
      '${newRoute != null ? _name(newRoute) : '?'}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    talker.info('[$label] remove ${_name(route)}');
  }
}

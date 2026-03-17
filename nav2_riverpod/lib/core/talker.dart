import 'package:talker_flutter/talker_flutter.dart';

/// Shared [Talker] instance used throughout the app.
///
/// Registered with:
/// - [TalkerRiverpodObserver] in [ProviderScope] — logs every provider
///   state change (create, update, dispose, error).
/// - [TalkerNavigatorObserver] on each [Navigator] (root + per-tab) —
///   logs push/pop/replace events with a label identifying the navigator.
/// - [TalkerScreen] at the logs route — in-app log viewer accessible from
///   the Account tab.
final talker = TalkerFlutter.init();

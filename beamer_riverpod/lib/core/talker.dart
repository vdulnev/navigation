import 'package:talker_flutter/talker_flutter.dart';

/// Shared [Talker] instance used throughout the app.
///
/// Registered with:
/// - [TalkerRiverpodObserver] in [ProviderScope] — logs every provider
///   state change (create, update, dispose, error).
/// - [TalkerScreen] at `/logs` — in-app log viewer accessible from the
///   Account tab.
final talker = TalkerFlutter.init();

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'core/talker.dart';
import 'router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // TalkerWrapper adds shake-to-open log screen on mobile and surfaces
    // Riverpod / routing errors as in-app alerts.
    return TalkerWrapper(
      talker: talker,
      options: const TalkerWrapperOptions(enableErrorAlerts: true),
      child: MaterialApp.router(
        title: 'Shop — GoRouter + Riverpod',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        routerConfig: router,
      ),
    );
  }
}

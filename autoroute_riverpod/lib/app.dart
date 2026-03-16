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

    return TalkerWrapper(
      talker: talker,
      options: const TalkerWrapperOptions(enableErrorAlerts: true),
      child: MaterialApp.router(
        title: 'Shop — AutoRoute + Riverpod',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        routerConfig: router.config(
          navigatorObservers: () => [TalkerRouteObserver(talker)],
        ),
      ),
    );
  }
}

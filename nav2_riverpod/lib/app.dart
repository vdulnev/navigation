import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'core/talker.dart';
import 'router/app_route_parser.dart';
import 'router/app_router_delegate.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delegate = ref.watch(routerDelegateProvider);

    return TalkerWrapper(
      talker: talker,
      options: const TalkerWrapperOptions(enableErrorAlerts: true),
      child: MaterialApp.router(
        title: 'Shop — Navigator 2 + Riverpod',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        routerDelegate: delegate,
        routeInformationParser: const AppRouteParser(),
      ),
    );
  }
}

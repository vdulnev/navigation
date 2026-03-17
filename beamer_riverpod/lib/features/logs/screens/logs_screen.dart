import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/talker.dart';

/// Full-screen log viewer backed by the shared [talker] instance.
class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TalkerScreen(talker: talker, appBarTitle: 'App Logs');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'app.dart';
import 'core/talker.dart';

void main() {
  runApp(
    ProviderScope(
      // Logs every provider create / update / dispose / error to [talker].
      observers: [TalkerRiverpodObserver(talker: talker)],
      child: const App(),
    ),
  );
}

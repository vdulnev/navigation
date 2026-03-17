import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/talker.dart';
import '../../../router/navigation_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// In-app log viewer — pushed as a full-screen page over the shell.
///
/// Navigator 2 concept: [LogsScreen] is a page in the root [Navigator]'s
/// stack, controlled by [NavigationState.showLogs]. Closing it calls
/// [NavigationNotifier.dismissLogs], which removes it from the page list
/// and causes the [Navigator] to pop the route automatically.
class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Logs'),
        leading: BackButton(
          onPressed: () => ref.read(navigationProvider.notifier).dismissLogs(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TalkerScreen(talker: talker, appBarTitle: ''),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: NavNoteCard(
              title: 'Navigator 2: page removal via state',
              body:
                  'LogsScreen is present in the root Navigator page list only '
                  'when NavigationState.showLogs is true. Calling '
                  'dismissLogs() sets it to false; the Navigator diffs the '
                  'page list and pops this route — no imperative pop needed.',
            ),
          ),
        ],
      ),
    );
  }
}

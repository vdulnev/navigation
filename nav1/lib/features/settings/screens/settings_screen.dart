import 'package:flutter/material.dart';

/// Simple settings screen to demonstrate plain push/pop.
///
/// Navigator 1 concepts demonstrated:
/// - Basic [Navigator.pop] — pressing the AppBar back arrow or the button
///   pops this route off the stack and returns to Home.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavNoteCard(
            title: 'Navigator 1: push / pop',
            body:
                'Home called Navigator.pushNamed(AppRoutes.settings).\n'
                'The AppBar back arrow (or the button below) calls '
                'Navigator.pop() to return.',
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('(UI only, no effect)'),
            value: false,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('(UI only, no effect)'),
            value: true,
            onChanged: (_) {},
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

class _NavNoteCard extends StatelessWidget {
  const _NavNoteCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
